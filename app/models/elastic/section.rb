module Elastic
  class Section < ActiveRecord::Base  
    extend WithToggles
    include WithKey
    include Tincan

    def tincan_map
       { 'structure_attrs' => %w{ key title localization is_star is_hidden is_locked is_pin form position },
         'structure_assoc' => %w{ structural_nodes content_configs },
         'content_attrs' => %w{ key title localization is_star is_hidden is_locked is_pin form position },
         'content_assoc' => %w{ nodes content_configs } }
    end
    
    attr_accessible :title, :key, :localization, :content_configs_attributes, :form, :position, :site_id, :section_id
    
    LOCALIZATIONS = %w{ free mirrored none }
    FORMS = %w{ blog tree files }

    belongs_to :site
    belongs_to :section
  
    has_many :content_configs, :dependent=>:destroy, :order=>:position
    has_many :nodes, :include=>{:contents=>:content_config}, :dependent=>:destroy, :order=>:position
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
    
    with_toggles :star, :hidden, :locked, :pin
    
    scope :ordered, order(:position)
  
    def to_s
      "[S] #{title}"
    end
    alias :name :to_s

    def to_nice
      "<span style='color: #008996'><span class='iconic cog'></span> #{title}</span>"
    end
    
    # --
        
    def structural_nodes
      is_pin? ? nodes : nodes.with_pin
    end        
        
    def fix_positions!
      for l in site.locales+[nil]
        fix_positions_for! nodes.roots.where(:locale=>l)
      end
    end
    
    def fix_positions_for!(the_nodes)
      the_nodes.each_with_index do |x,index|
        x.update_attribute :position, index+1
        fix_positions_for! x.children
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
    
    # -- file mirroring --

    # # file mirroring
    # def mirror_to_disk!
      # raise RuntimeError, "Key is blank. Where to save?" if key.blank?
      # raise RuntimeError, "Section key is blank. Where to save?" if section.key.blank?
    # end
    
    # def mirror!
    #   raise RuntimeError, "Section form 'files' expected. Can not mirror." unless form == 'files'
    #   raise RuntimeError, "Blank section key. Can not mirror." if key.blank?
    #   
    #   for n in nodes
    #     the_path = File.join site.home_dir, 'themes', key, "fakof.txt"
    #     
    #     Rails.logger.info "path #{the_path}"
    #   end
    #   
    # end
    #   
    # -- wake --
  
    def wake_destroyable?
      nodes.empty? 
    end
  end
end