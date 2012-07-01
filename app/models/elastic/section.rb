module Elastic
  class Section < ActiveRecord::Base  
    extend WithToggles
    include WithKey
    include Tincan

    def tincan_map
       { 'structure_attrs' => %w{ key title localization is_star is_hidden is_locked form position },
         'structure_assoc' => %w{ structural_nodes content_configs },
#         'structure_assoc' => %w{ content_configs },
         'content_attrs' => %w{ key },
         'content_assoc' => %w{ nodes } }
    end
    
    attr_accessible :title, :key, :localization, :content_configs_attributes, :form, :position, :site_id
    
    LOCALIZATIONS = %w{ free mirrored none }
    FORMS = %w{ blog tree }

    belongs_to :site
    belongs_to :section
  
    has_many :content_configs, :dependent=>:destroy, :order=>:position
    has_many :nodes, :include=>{:contents=>:content_config}, :dependent=>:destroy #, :order=>lambda{ |x| raise 'fuck' }  
#    has_many :nodes, :conditions=>lambda{ |x| x.master_node_id ? }

    acts_as_list :scope=>:site_id
  
    accepts_nested_attributes_for :content_configs, :allow_destroy => true

    validates_presence_of :key, :title
    validates_uniqueness_of :key, :scope=>:site_id
    
    validates_inclusion_of :localization, :in=>LOCALIZATIONS
    validates_inclusion_of :form, :in=>FORMS
  
    before_destroy :wake_destroyable?
    before_validation :generate_key, :if=>lambda{ |x| x.key.blank? }
#    before_validation :keep_context
    after_save :sync_keys!
    
    with_toggles :star, :hidden, :locked, :pin
    
    scope :ordered, order(:position)
        
    def structural_nodes
      is_pin? ? nodes : nodes.with_pin
    end
        
    def sync_keys!
      return true if not key_changed?
      nodes.map{ |x| x.update_attribute :section_key, key }
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