module Elastic  
  class Content < ActiveRecord::Base

    has_paper_trail    
    
    attr_accessible :content_config, :node, :content_config_id, :node_id, :text, :locale, :file, :reference_id, :reference_type
  
    belongs_to :content_config
    belongs_to :node
      
    def file=(x)
      FileUtils.cp x.tempfile.path, File.join(content_config.gallery.filepath,'orig',x.original_filename)      
      self.text = x.original_filename
      content_config.gallery.sync!
      self.reference = content_config.gallery.file_records.where(:filename=>x.original_filename).first
#      raise self.reference_id.inspect
    end

    def reference(reload=false)
      return nil if reference_id == nil
      @reference = nil if reload
      @reference ||= reference_type.constantize.find_by_id reference_id
    end

    def published_reference(reload=false)
      return nil if published_reference_id == nil
      @published_reference = nil if reload
      @published_reference ||= published_reference_type.constantize.find_by_id published_reference_id
    end

    
    def reference=(x)
      if x == nil
        self.reference_id = nil
        self.reference_type = nil
      else
        self.reference_id = x.id
        self.reference_type = x.class.to_s
      end
    end

    # -- wake --
  
    def self.wake_includes
      :content_config
    end
  end
end