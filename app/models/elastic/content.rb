module Elastic  
  class Content < ActiveRecord::Base
    include Tincan
    
    def tincan_map      
      { 'structure_attrs' => %w{ text locale content_config_key },
        'structure_assoc' => %w{ },
        'content_attrs' => %w{ text locale content_config_key },
        'content_assoc' => %w{ } }
    end

    has_paper_trail    
    
    attr_accessible :content_config, :node, :content_config_id, :node_id, :text, :locale, :file, :reference_id, :reference_type, :reference_remove
  
    belongs_to :content_config, :readonly=>true
    belongs_to :node
      
    def file=(x)
      @file = x
      FileUtils.cp x.tempfile.path, File.join(content_config.gallery.filepath,'orig',x.original_filename)      
      content_config.gallery.sync!
      self.reference = content_config.gallery.file_records.where(:filename=>x.original_filename).first
    end
    
    def reference_remove=(x)
      self.reference = nil if x=='on'
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
    
    def blank?
      reference_id ? reference.nil? : text.blank?
    end

    # -- wake --
  
    def self.wake_includes
      :content_config
    end
  end
end