module Elastic
  class ContentConfig < ActiveRecord::Base
    extend WithToggles
    include Tincan
    include WithKey

    def tincan_map
       { 'structure_attrs' => %w{ key title position form meta is_published },
         'structure_assoc' => %w{ },
         'content_attrs' => %w{ key title position form meta is_published },
         'content_assoc' => %w{ }, } # 
    end
    
    attr_accessible :position, :title, :form, :meta, :key
  
    FORMS = {
      :textfield => %w{ size },
      :textarea => %w{ cols rows },
      :selectbox => %w{ values },
      :image => %w{ gallery_key variant },
      :node => %w{ section_key },
      :gallery => %w{ },
      :tinymce => %w{ config_file }
    }
    
  
    belongs_to :section  
    has_many :contents
    has_many :nodes, :through=>:contents
    before_destroy :wake_destroyable?
    before_validation :saturate
    before_validation :generate_key, :if=>lambda{ |x| x.key.blank? }
    after_save :sync_keys
  
    acts_as_list :scope=>:section_id # 'section_id = #{section_id}'
  
    scope :published, where(:is_published=>true)
  
    validates_presence_of :title, :form, :position, :key  
    validates_uniqueness_of :key, :scope=>:section_id
    serialize :meta
    
    with_toggles :published


    def gallery(force=false)
      @gallery = nil if force
      @gallery ||= begin
        ret = section.site.galleries.find_by_key meta['gallery_key']
        ret
      end
    end

  
    # def toggle_published!
    #   update_attribute :is_published, !is_published?
    # end
    
    def sync_keys
      return true if not key_changed?
      contents.map{ |x| x.update_attribute :content_config_key, key }
    end
    
    def saturate
      self.position ||= section.content_configs.count+1
      self.meta ||= {}
      self.meta[:config_file] = meta[:config_file].gsub /[^a-zA-Z0-9\-_.]/, '' if meta[:config_file]
    end
    
    def wake_destroyable?
      contents.empty?
    end
  end
end