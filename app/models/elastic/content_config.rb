module Elastic
  class ContentConfig < ActiveRecord::Base
    
    attr_accessible :position, :title, :form, :meta
  
    FORMS = {
      :textfield => %w{ size },
      :textarea => %w{ size },
      :selectbox => %w{ values },
      :image => %w{ tn_w tn_h img_w img_h tn_magick img_magick }
    }
  
    belongs_to :section  
    has_many :contents
  
    acts_as_list :scope=>:section_id # 'section_id = #{section_id}'
  
    scope :published, where(:is_published=>true)
  
    validates_presence_of :title
  
    serialize :meta
  
    def toggle_published!
      update_attribute :is_published, !is_published?
    end
    
    def wake_destroyable?
      contents.empty?
    end
  end
end