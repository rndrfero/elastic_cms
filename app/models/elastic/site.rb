module Elastic  
  class Site < ActiveRecord::Base
#    include WithKey
    
    attr_accessible :host, :title, :locales_str, :theme, :is_force_reload_theme, :index_locale, :locale_to_index_hash, :gallery_meta, :theme_index, :theme_layout, :master_id, :gallery_id
 
    include Elastic::WithDirectory
      
    has_many :sections, :order=>:position, :dependent=>:destroy
    has_many :nodes, :dependent=>:destroy
    has_many :template_caches #, :dependent=>:destroy
    has_many :galleries, :dependent=>:destroy
    
    belongs_to :master, :class_name=>'User', :foreign_key=>'master_id'
    has_many :users
    belongs_to :master_gallery, :class_name=>'Gallery', :dependent=>:destroy
  
    validates_presence_of :title, :host
    validates_format_of :host, :with=>/^[a-z0-9.]*$/
    validates_presence_of :locales_str
    validates_uniqueness_of :host
  
    serialize :locales
    serialize :locale_to_index_hash

    before_validation :saturate
#    before_validation :generate_key, :if=>lambda{ |x| x.key.blank? }
    before_destroy :wake_destroyable? 
    after_save :integrity!
    after_create { |x| x.create_gallery!(:title=>'DEFAULT SETTINGS', :site_id=>x.id, :is_hidden=>true) }
  
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
        
      
    def theme_list
      return nil if new_record?
      Dir.entries(home_dir+'themes').reject!{ |x| x.starts_with? '.' or !File.directory?(home_dir+'themes/'+x) }
    end
    
    def theme_liquids
      return [] if theme.blank?
      Dir.entries(theme_dir).reject!{ |x| not x.ends_with? '.liquid' }.map!{ |x| x.gsub! /\.liquid$/, '' }
    end
  
    # ensure site integrity
    def integrity!
      return if new_record?
      
      self.theme ||= 'hello_world'
      
      if host_changed? and File.exists? home_dir(host_was)
        x = home_dir(host_was)+'current_theme'
        FileUtils.remove_entry_secure x if File.exists? x
        File.rename home_dir(host_was), home_dir
      end
      
      
      create_or_rename_dir! home_dir
      for x in %w{ themes/hello_world static galleries }
        FileUtils.mkdir_p File.join(home_dir,x)
      end
      x = File.join(home_dir, 'themes/hello_world')
      FileUtils.remove_entry_secure x if File.exists? x
      FileUtils.cp_r File.join(Rails.root, '../themes/hello_world'), File.join(home_dir, 'themes')
      
      # create symlink to current_theme
      x = home_dir+'current_theme'
#     File.unlink x if File.exists? x
     FileUtils.remove_entry_secure x if File.exists? x
#     raise "#{theme_dir} -> #{home_dir}"
     FileUtils.symlink theme_dir, home_dir+'current_theme'
    end


    private
    
    def saturate
      self.locales_str = 'en'
    end
  
  
    # -- wake --
    def wake_destroyable?
      nodes.empty? and galleries.empty?
    end

  end  
end
