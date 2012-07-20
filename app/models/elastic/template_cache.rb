module Elastic
  class TemplateCache < ActiveRecord::Base
    attr_accessible :key
  
    belongs_to :site
  
    validates_presence_of :key
    validates_uniqueness_of :key

    def template
      self[:template] ? Marshal.load(self[:template]) : nil
    end

    def template=(x)
      self[:template] = Marshal.dump(x)
    end
  
    def self.init(name)        
      Liquid::Template.file_system = Liquid::LocalFileSystem.new Context.site.home_dir
      
      ret = TemplateCache.new :key=>"#{Context.site.id}-#{name}"
    
      filepath = Context.site.home_dir + name # + '.liquid'
        
      ret.template = File.open(filepath, 'r') do |f| 
        Liquid::Template.parse f.read
      end
      ret.save!
      ret
    end  
  
    def self.render(name, drops)
      row = TemplateCache.where(:key=> "#{Context.site.id}-#{name}").first    
      Liquid::Template.file_system = Liquid::LocalFileSystem.new Context.site.home_dir      
    
      if Context.site.is_reload_theme?
        row.destroy if row
        row = TemplateCache.init name 
      end
    
      row ||= TemplateCache.init name     
      row.template.render drops
    end 
    
    def self.clear!
      ActiveRecord::Base.connection.delete 'DELETE FROM template_caches'    
    end
  
  end
end