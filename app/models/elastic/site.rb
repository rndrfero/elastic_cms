require_dependency 'elastic/tincan'

module Elastic  
  class Site < ActiveRecord::Base
    include Tincan
    extend WithToggles
#    include WithKey

    def tincan_map
       { 'structure_attrs' => %w{ locales theme_index theme_layout },
         'structure_assoc' => %w{ structural_galleries master_gallery sections },
         'content_attrs' => %w{ title index_locale locale_to_index_hash },
         'content_assoc' => %w{ galleries sections } } # 
    end
    
    attr_accessible :host, :title, :locales_str, :theme, :is_reload_theme, :index_locale, :locale_to_index_hash, :gallery_meta, 
      :theme_index, :theme_layout, :master_id, :master_gallery_id, :bg_gallery_id, :bg_color, :structure_import, :content_import
 
    include Elastic::WithDirectory
      
    has_many :sections, :order=>:position, :dependent=>:destroy
#    has_many :nodes, :include=>[:section, :content_configs, :contents],:dependent=>:destroy
    has_many :template_caches #, :dependent=>:destroy
    has_many :galleries, :dependent=>:destroy
    has_many :nodes, :through=>:sections, :dependent=>:destroy
    
    belongs_to :master, :class_name=>'User', :foreign_key=>'master_id'
    has_many :users
    # belongs_to :master_gallery, :class_name=>'Gallery', :foreign_key=>'master_gallery_id', :dependent=>:destroy
    # belongs_to :bg_gallery, :class_name=>'Gallery', :foreign_key=>'bg_gallery_id', :dependent=>:destroy
    belongs_to :master_gallery, :class_name=>'Gallery', :dependent=>:destroy
    belongs_to :bg_gallery, :class_name=>'Gallery', :dependent=>:destroy
    
    with_toggles :reload, :reload_theme
  
    validates_presence_of :title, :host
    validates_format_of :host, :with=>/^[a-z0-9.\-]*$/
    validates_presence_of :locales_str
    validates_uniqueness_of :host
  
    serialize :locales
    serialize :locale_to_index_hash

    before_validation :saturate
#    before_validation :generate_key, :if=>lambda{ |x| x.key.blank? }
    before_destroy :wake_destroyable? 
    after_save :integrity!
  
    def locales_str
      (locales||[]).join(', ')
    end
  
    def locales_str=(x)
      self.locales = x.split(',').map{ |x| x.strip }.uniq
    end
  
    def uri
      'http://'+host
    end
  
    # -- directories --
    
    def home_dir(x=nil)
      x ||= host
      File.join Rails.root, "/home/#{x}/"
    end      
    
    def theme_dir
      home_dir + 'themes/' + theme.gsub(/^[^a-z0-9.]/,'') + '/'
    end
    
    def du
      `du -s #{home_dir}`.to_i
    end
        
    def theme_valid?
      not theme.blank? and File.directory?(theme_dir)
    end
      
    def theme_list
#      return nil if new_record?
      Dir.entries(home_dir+'themes').reject!{ |x| x.starts_with? '.' or !File.directory?(home_dir+'themes/'+x) }
    end
    
    def theme_liquids
#      return [] if theme.blank?      
      Dir.entries(theme_dir).reject!{ |x| not x.ends_with? '.liquid' }.map!{ |x| x.gsub! /\.liquid$/, '' }
    end
  
    # ensure site integrity
    def integrity!
      return if new_record?
      Elastic.logger_info "Site.integrity! for #{host}"
      
      if host_changed? and File.exists? home_dir(host_was)
        x = home_dir(host_was)+'current_theme'
        FileUtils.remove_entry_secure x if File.exists? x
        File.rename home_dir(host_was), home_dir
      end
      
#      copy_themes!
      
      create_or_rename_dir! home_dir
      for x in %w{ themes static galleries }
        FileUtils.mkdir_p File.join(home_dir,x)
      end
            
      # create symlink to current_theme
      x = home_dir+'current_theme'
      FileUtils.remove_entry_secure x if File.exists?(x)||File.symlink?(x)
      FileUtils.symlink theme_dir, x

      # create master gallery when there is none
#      raise "kokot: #{self.master_gallery(true).inspect}"
      unless master_gallery
        x = create_master_gallery! :title=>'DEFAULT SETTINGS', :site_id=>self.id, :is_dependent=>false, :is_hidden=>true
        update_attribute :master_gallery_id, x.id
      end
     
      true
    end
    
    def copy_themes!
      themes = %w{ hello_world test-contents test-welcome }
      Elastic.logger_info "Copying themes: #{themes}"
      for t in themes
        x = File.join home_dir, 'themes', t
        FileUtils.remove_entry_secure x if File.exists? x
        FileUtils.cp_r File.join(Rails.root, '../themes',t), File.join(home_dir, 'themes')
      end
    end
    
    def self.clean!
      ret = []
      for x in Dir.entries Rails.root+'home'
        next if x.starts_with? '.'
        next if Site.where(:host=>x).exists?
        ret << x
      end
      for x in ret
        FileUtils.remove_entry_secure File.join(Rails.root+'home',x)
      end      
    end
    
    
    def master_gallery_meta
      master_gallery ? master_gallery.meta : {}
    end
    
    # -- structure import/export --
    
    def structural_galleries
      galleries.where('is_pin = ? OR is_hidden = ?', true, true).all
    end

    def theme_structure_filename
      Dir.entries(theme_dir).select{ |x| x=~/structure.tar/ }.first
    end

    def theme_content_filename
      Dir.entries(theme_dir).select{ |x| x=~/content.tar/ }.first
    end
    
    def export(what)
      raise 'unexpected' unless what=='content' or what=='structure'
      yaml = YAML::dump tincan_dump(what)
      File.open(home_dir+"#{what}.yaml", 'w') {|f| f.write(yaml) }
      exclude_list = ""
      (galleries-structural_galleries).each{ |x| exclude_list<<" --exclude #{x.key}" } if what=='structure'
      `cd home/#{host}; tar -c --exclude themes --exclude current_theme#{exclude_list} .`      
    end
        
    def import!(what)
      raise 'unexpected' unless what=='content' or what=='structure'
      transaction do
        o, e, s = Open3.capture3("tar xv -C #{home_dir}", :stdin_data=>x.force_encoding('utf-8'))
      
        raise "untar failed" if s!=0
        raise "#{what}.yaml not present" if not File.exists?(home_dir+"#{what}.yaml")
      
        # load content
        tincan_load what, YAML::load(File.open(home_dir+"#{what}.yaml").read)

        # resync node.content_config_id
        for n in nodes
          for c in n.contents
            cc = ContentConfig.where(:section_id=>n.section_id, :key=>c.content_config_key).first
            raise "content config '#{c.content_config_key}' not found"
            c.update_attribute :content_config_id, cc.id
          end
        end
      end
    
    
    # def export_structure
    #   YAML::dump tincan_dump('structure')
    # end
    # 
    # def import_structure!(x)
    #   transaction do
    #     tincan_load 'structure', YAML::load(x)
    #   end
    # end

    # -- content import/export --
    #      tar -cf ~/Desktop/backup.tar --exclude home/inout.local/themes --exclude home/inout.local/current_theme home/inout.local

    # def export_content
    #   content = YAML::dump tincan_dump('content')
    #   filename = File.join home_dir, 'content.yaml'
    #   File.open(filename, 'w') {|f| f.write(content) }
    #   
    #   `cd home/#{host}; tar -c --exclude themes --exclude current_theme .`      
    # end
    
    # def import_content!(x)
    #   transaction do
    #     o, e, s = Open3.capture3("tar xv -C #{home_dir}", :stdin_data=>x.force_encoding('utf-8'))
    #   
    #     raise "untar failed" if s!=0
    #     raise "content.yaml not present" if not File.exists?(home_dir+'content.yaml')
    #   
    #     # load content
    #     tincan_load 'content', YAML::load(File.open(home_dir+'content.yaml').read)
    # 
    #     # resync node.content_config_id
    #     for n in nodes
    #       for c in n.contents
    #         cc = ContentConfig.where(:section_id=>n.section_id, :key=>c.content_config_key).first
    #         raise "content config '#{c.content_config_key}' not found"
    #         c.update_attribute :content_config_id, cc.id
    #       end
    #     end
    #   end
      
      # rescan galleries
      
      # tidy up
    end
    
    
    # def theme_content_filename
    # end
    

    private
    
    def saturate
      # default values
      self.theme = 'hello_world' if theme.blank?
      self.locales_str = 'en' if locales_str.blank?
      self.title = host if title.blank?
      self.is_reload_theme = true if new_record?
    end
  
  
    # -- wake --
    def wake_destroyable?
      nodes.empty? and galleries.empty?
    end

  end  
end
