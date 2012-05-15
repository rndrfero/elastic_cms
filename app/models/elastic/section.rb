module Elastic
  class Section < ActiveRecord::Base  
    extend WithToggles
    
    attr_accessible :title, :key, :localization, :content_configs_attributes
    
    LOCALIZATIONS = %w{ free mirrored none }

    belongs_to :site
    belongs_to :section
  
    has_many :content_configs, :dependent=>:destroy, :order=>:position
    has_many :nodes  
  
    accepts_nested_attributes_for :content_configs, :allow_destroy => true

    validates_presence_of :key, :title
    validates_format_of :key, :with=>/^[a-zA-Z0-9\-_]*$/
    validates_uniqueness_of :key, :scope=>:site_id
  
    before_destroy :wake_destroyable?
    before_validation :keep_context
    
    with_toggles :star, :hidden, :locked

    # -- kontext --

    def keep_context
      self.site_id = Context.site.id
    end
  
    # -- wake --
  
    def wake_destroyable?
      nodes.empty? 
    end
  end
end