module Elastic
  class Section < ActiveRecord::Base  
    extend WithToggles
    
    attr_accessible :title, :key, :localization, :content_configs_attributes, :form
    
    LOCALIZATIONS = %w{ free mirrored none }
    FORMS = %w{ blog tree }

    belongs_to :site
    belongs_to :section
  
    has_many :content_configs, :dependent=>:destroy, :order=>:position
    has_many :nodes #, :order=>lambda{ |x| raise 'fuck' }  
  
    accepts_nested_attributes_for :content_configs, :allow_destroy => true

    validates_presence_of :key, :title
    validates_format_of :key, :with=>/^[a-zA-Z0-9\-_]*$/
    validates_uniqueness_of :key, :scope=>:site_id
    validates_inclusion_of :localization, :in=>LOCALIZATIONS
    validates_inclusion_of :form, :in=>FORMS
  
    before_destroy :wake_destroyable?
    before_validation :keep_context
    
    with_toggles :star, :hidden, :locked

    # -- kontext --

    def keep_context
      self.site_id = Context.site.id
    end
    
    def fix_positions!(the_nodes=nodes.roots.all)
      the_nodes.each_with_index do |x,index|
        x.update_attribute :position, index+1
        fix_positions! x.children
      end
    end
    
    # -- versioning --
    
    def reify_nodes
      versions = Version.where(:item_type=>'Elastic::Node', :event=>'destroy').order(:created_at).all.reverse
#      raise @versions.inspect
      nodes = []
      for v in versions        
        next if not n = v.reify
        next if not n.section_id == self.id # not this section
        next if self.node_ids.include? n.id # exists
        next if nodes.map{ |x| x.id }.include? n.id # allready there
        n.reify_contents v.created_at
        nodes << n
      end
      nodes
    end
    
  
    # -- wake --
  
    def wake_destroyable?
      nodes.empty? 
    end
  end
end