module Elastic  
  class Site < ActiveRecord::Base
      
    has_many :sections
    has_many :nodes
    has_many :template_caches
  
    validates_presence_of :title, :host
    validates_presence_of :locales_str
  
    serialize :locales
    serialize :locale_to_index_hash

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
      File.join Rails.root, "home/#{id}/"
    end
    
    def theme_dir
      home_dir + 'themes/' + theme.to_filename + '/'
    end
  
    def theme_list
      return nil if new_record?
      Dir.entries(home_dir+'themes').reject!{ |x| x.starts_with? '.' or !File.directory?(home_dir+'themes/'+x) }
    end
  
    # ensure site integrity
    def integrity!
      return if new_record?
      for x in %w{ themes/hello_world static data }
        FileUtils.mkdir_p File.join(Rails.root,'home',"#{self.id}", x)
      end
    end
  
  
    # -- wake --
    # def wake_destroyable?
    #   nodes.empty?
    # end

  end  
end
