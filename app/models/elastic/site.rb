module Elastic  
  class Site < ActiveRecord::Base
    include Elastic::WithDirectory
      
    has_many :sections
    has_many :nodes
    has_many :template_caches
    has_many :galleries
  
    validates_presence_of :title
    validates_format_of :host, :with=>/^[a-z0-9.]*$/
    validates_presence_of :locales_str
  
    serialize :locales
    serialize :locale_to_index_hash
    serialize :galleries_meta

    before_destroy :wake_destroyable? 
    after_save :integrity!
  
    def locales_str
      (locales||[]).join(', ')
    end
  
    def locales_str=(x)
      self.locales = x.split(',').map{ |x| x.strip }.uniq
    end
  

  
    # -- directories --
  
    def home_dir
      File.join Rails.root, "home/#{id}-#{host}/"
    end
    
    def theme_dir
      home_dir + 'themes/' + theme.gsub(/^[^a-z0-9.]/,'') + '/'
    end
  
    def theme_list
      return nil if new_record?
      Dir.entries(home_dir+'themes').reject!{ |x| x.starts_with? '.' or !File.directory?(home_dir+'themes/'+x) }
    end
  
    # ensure site integrity
    def integrity!
      return if new_record?
      create_or_rename_dir! home_dir
      for x in %w{ themes/hello_world static galleries }
        FileUtils.mkdir_p File.join(home_dir,x)
      end
      FileUtils.remove_entry_secure File.join(home_dir, 'themes/hello_world')
      FileUtils.cp_r File.join(Rails.root, '../themes/hello_world'), File.join(home_dir, 'themes')
    end
  
  
    # -- wake --
    # def wake_destroyable?
    #   nodes.empty?
    # end

  end  
end
