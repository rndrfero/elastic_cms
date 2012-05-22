module Elastic  
  class Content < ActiveRecord::Base

    has_paper_trail    
    
    attr_accessible :content_config, :node, :content_config_id, :node_id, :text, :locale, :file
  
    belongs_to :node
    belongs_to :content_config
  
  #  validates_presence_of :node
  
    def file=(x)
      FileUtils.cp x.tempfile.path, File.join(content_config.gallery.filepath,'orig',x.original_filename)      
      self.text = x.original_filename
      content_config.gallery.sync!
    end
    

    # -- wake --
  
    def self.wake_includes
      :content_config
    end
  end
end