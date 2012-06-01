module Elastic
  class ContentConfig < ActiveRecord::Base
    extend WithToggles
    
    attr_accessible :position, :title, :form, :meta, :is_live
  
    FORMS = {
      :textfield => %w{ size },
      :textarea => %w{ cols rows },
      :selectbox => %w{ values },
      :image => %w{ gallery_id variant },
      :node => %w{ section_key },
      :gallery => %w{ },
      :tinymce => %w{ config_file }
    }
  
    belongs_to :section  
    has_many :contents
    has_many :nodes, :through=>:contents
    before_destroy :wake_destroyable?
    before_validation :saturate
  
    acts_as_list :scope=>:section_id # 'section_id = #{section_id}'
  
    scope :published, where(:is_published=>true)
  
    validates_presence_of :title, :form, :position  
    serialize :meta
    
    with_toggles :published


    def gallery(force=false)
      @gallery = nil if force
      @gallery ||= begin
        ret = Gallery.find_by_id meta['gallery_id']
        ret = nil if ret.site_id != section.site_id if ret
        ret
      end
    end

  
    # def toggle_published!
    #   update_attribute :is_published, !is_published?
    # end
    
    def saturate
      self.meta ||= {}
      self.meta[:config_file] = meta[:config_file].gsub /[^a-zA-Z0-9\-_.]/, '' if meta[:config_file]
    end
    
    def wake_destroyable?
      contents.empty?
    end
  end
end