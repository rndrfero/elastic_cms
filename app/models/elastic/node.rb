module Elastic
  class Node < ActiveRecord::Base
    include WithKey
    extend WithToggles
    include Tincan
    
    def tincan_map
      { 'structure_attrs' => %w{ key section_key title title_loc locale parent_key is_star is_published published_at position },
        'structure_assoc' => %w{ contents },
        'content_attrs' => %w{ key section_key title title_loc locale parent_key is_star is_published published_at position },
        'content_assoc' => %w{ contents } }
    end

    has_paper_trail :ignore => [:title, :locale, :is_star, :is_published, :published_at, :is_locked, :parent_id, :position, :redirect, :published_version_id]
    
    attr_accessible :section, :locale, :title_dynamic, :key, :is_published, :is_star, :position, :contents_setter, :redirect, :published_at, :parent_key_human
  
    serialize :title_loc
  
    has_many :contents, :dependent=>:destroy, :include=>:content_config, :order=>'elastic_content_configs.position'
#    has_many :content_configs, :through=>:content
    belongs_to :section
    belongs_to :site
    belongs_to :published_version, :class_name=>'Version', :foreign_key=>'published_version_id'    
  
    #accepts_nested_attributes_for :contents
  
    has_ancestry :cache_depth =>true
#    acts_as_list :scope=>'section_id = #{section_id} AND #{ancestry ? "ancestry = \'#{ancestry}\'" : \'ancestry IS NULL\'}'
    # acts_as_list :scope=>'section_id #{section ? "= #{section_id}" : "IS NULL"} AND 
    #   ancestry #{ancestry ? "= \'#{ancestry}\'" : \'IS NULL\'} AND
    #   locale #{locale ? "= \'#{locale}\'" : \'IS NULL\'}'
    acts_as_list :scope=>'section_id #{section ? "= #{section_id}" : "IS NULL"} AND ancestry #{ancestry ? "= \'#{ancestry}\'" : \'IS NULL\'}'
  
    validates_presence_of :section, :key
    validates_presence_of :title_dynamic

#    validates_format_of :key, :with=>/^[a-zA-Z0-9\-_]*$/
    validates_uniqueness_of :key, :scope=>:site_id
    validates_inclusion_of :locale, :in=>lambda{ |x| x.site.locales }, :if=>lambda{ |x| x.section.localization=='free' }
    validates_presence_of :published_at, :if=>lambda{ |x| x.section.form == 'blog' }
  
    before_validation { self.site_id = self.section.site_id if self.section }
    before_validation :generate_key_from_dynamic_title, :if=>lambda { |x| x.key.blank? }
#    before_validation :keep_context
    before_save :inc_version_cnt
    before_destroy :wake_destroyable?

  
    scope :published, where(:is_published=>true).order('ancestry_depth,position')
    scope :roots, where(:ancestry=>nil).order('ancestry_depth,position')
    scope :localized, lambda { where(:locale=>Context.locale) }
    scope :tree_ordered, :order=>"ancestry_depth,position DESC"
    scope :date_ordered, :order=>"published_at"
    scope :starry, where(:is_star=>true)
    scope :with_pin, where(:is_pin=>true)
    scope :in_public, lambda { includes(:contents=>:content_config).where(:site_id=>Context.site.id) }
    
    with_toggles :star, :locked, :published, :pin

    #    .section.form=='blog' ? reorder("published_at") : reorder("ancestry_depth,position DESC"
    
    # -- key --
    
    def generate_key_from_dynamic_title
      generate_key title_dynamic
    end  
    
    def parent_key_human
      parent ? "#{parent.title_dynamic} [#{parent.key}]" : nil
    end
    
    def parent_key_human=(x)
      the_key = x.match(/\[.*\]/)
      # means "Home [home]"
      the_key = the_key[0].chop.reverse.chop.reverse if the_key
      # means "home"
      the_key ||= x
      

      n = section.nodes.find_by_key the_key
      self.parent_key = n ? the_key : nil
      self.parent_id = n ? n.id : nil
      x
    end
    
  
    # -- versioning --
      
    attr :reifyied_contents, true
    
    def reify_contents(timestamp)
      ret = []
      for v in Version.where(:event=>'destroy',:created_at=>timestamp, :item_type=>'Elastic::Content').all
        c = v.reify
        next unless c and c.node_id == id
        ret << c
      end
      self.reifyied_contents = ret
    end
    
    def inc_version_cnt
      self.version_cnt = (self.version_cnt||0)+1 if @changed
    end
    
    # -- contents --
    
    def contents_blank?
      #contents.reduce{ |ret,x| ret and x.blank? }
      return false unless redirect.blank?
      contents.map{ |x| return false unless x.blank? }
      true
    end
  
    def content_getter(cc_id)
      Rails.logger.debug "content_getter"
      cc_id = cc_id.id if cc_id.is_a? ContentConfig
      cc_id = cc_id.to_i if cc_id.is_a? String
      if section.localization == 'mirrored'
        contents.select{ |x| x.content_config_id==cc_id and x.locale==Context.locale }.first
#        contents.where(:content_config_id=>cc_id, :locale=>Context.locale).first
      else
        contents.select{ |x| x.content_config_id==cc_id }.first
#        contents.where(:content_config_id=>cc_id).first
      end
    end
    
    # def content_getter_position(position)
    #   if section.localization == 'mirrored'
    #     contents.where(:position=>position,:locale=>locale).first # select{ |x| x.position==position and x.locale==Context.locale }.first
    #   else
    #     contents.where(:position=>position).first
    #   end      
    # end
  
    def contents_setter=(cc_id_to_attrs_hash)
      Rails.logger.debug "content_setter"
      if section.localization == 'mirrored'
        for cc_id, attrs in cc_id_to_attrs_hash
          c = content_getter cc_id 
          c ||= Content.new :content_config_id=>cc_id, :node=>self, :locale=>Context.locale
#          c.update_attributes attrs
          c.attributes= attrs
          @changed = true if c.text_changed? or c.reference_id_changed? or c.reference_type_changed?
          c.save
        end
      else
        for cc_id, attrs in cc_id_to_attrs_hash
          c = content_getter cc_id 
          c ||= Content.new :content_config_id=>cc_id, :node=>self
          c.attributes= attrs
          @changed = true if c.text_changed? or c.reference_id_changed? or c.reference_type_changed?
#           if c.text_changed?  or c.binary_changed?
          c.save
#          c.update_attributes attrs
        end      
      end
    end  
  
    # -- localized title --
    
    def title_dynamic
      if section
        section.localization == 'mirrored' ? (title_loc||{})[Context.locale] : title
      else
        title||title_loc
      end
    end
  
    def title_dynamic=(x)
      if section.localization == 'mirrored'
        self.title_loc ||= {}
        self.title_loc[Context.locale] = x
      else
        self.title= x
      end
    end
    
    def publish_version!(the_version)
      self.update_attribute :published_version_id, the_version.id
      timestamp = the_version.created_at
      for c in contents
        the_c = c.version_at(timestamp)
        c.update_attribute :published_text, the_c.text
        c.update_attribute :published_reference_id, the_c.reference_id
        c.update_attribute :published_reference_type, the_c.reference_type
      end
    end
    
    def publish_recent!
      self.published_version = nil
      for c in contents
        c.update_attribute :published_text, nil
        c.update_attribute :published_reference_id, nil
        c.update_attribute :published_reference_type, nil
      end
      self.save!
    end
    
    # def published_at_str 
    #   published_at.to_s
    # end
    # 
    # def published_at_str=(x)
    #   DateTime.parse x
    # end
  
    
    # def keep_context
    #   self.site_id = Context.site.id
    #   self.locale = Context.locale if section.localization == 'free' if locale.blank?
    # end

    # -- wake --
  
    def wake_includes
      { :contents => :content_config }
    end
  
    def wake_destroyable?
      children.empty? and !is_locked?
    end
    
  end
end