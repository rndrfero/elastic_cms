#require_dependency 'strip_diacritic'
require 'iconv'

module Elastic
  class Node < ActiveRecord::Base
    include WithKey
    extend WithToggles

    has_paper_trail    
    
    attr_accessible :section, :locale, :title, :key, :is_published, :is_star, :parent_id, :position, :contents_setter
  
    serialize :title_loc
  
    has_many :contents
    belongs_to :section
  
    #accepts_nested_attributes_for :contents
  
    has_ancestry :cache_depth =>true
    acts_as_list :scope=>'section_id = #{section_id} AND #{ancestry ? "ancestry = \'#{ancestry}\'" : \'ancestry IS NULL\'}'
  
    validates_presence_of :title, :section, :key
#    validates_format_of :key, :with=>/^[a-zA-Z0-9\-_]*$/
    validates_uniqueness_of :key, :scope=>:site_id
  
    before_validation :generate_key
    before_validation :keep_context
    before_save :inc_version_cnt
    before_save :fix_positions
  
    scope :published, where(:is_published=>true).order('ancestry_depth,position DESC')
    scope :roots, where(:ancestry=>nil).order('ancestry_depth,position DESC')
    scope :localized, lambda { where(:locale=>Context.locale) }
    scope :ordered, :order => "ancestry_depth,position DESC"
    scope :starry, where(:is_star=>true)
    
    with_toggles :star, :locked, :published
    
  
    # scope :localized, lambda do |user_ids| 
    #   section.localization == 'free' ? where(:locale=>CurrentContext.locale) unless user_ids.empty?
    # end
    
    def inc_version_cnt
      self.version_cnt = (self.version_cnt||0)+1 if @changed
    end
  
    def content_getter(cc_id)
      cc_id = cc_id.id if cc_id.is_a? ContentConfig
      cc_id = cc_id.to_i if cc_id.is_a? String
      if section.localization == 'mirrored'
        contents.select{ |x| x.content_config_id==cc_id and x.locale==Context.locale }.first
      else
        contents.select{ |x| x.content_config_id==cc_id }.first
      end
    end
  
    def contents_setter=(cc_id_to_attrs_hash)
      if section.localization == 'mirrored'
        for cc_id, attrs in cc_id_to_attrs_hash
          c = content_getter cc_id 
          c ||= Content.new :content_config_id=>cc_id, :node=>self, :locale=>Context.locale
#          c.update_attributes attrs
          c.attributes= attrs
          @changed = true if c.text_changed? or c.binary_changed?
          c.save
        end
      else
        for cc_id, attrs in cc_id_to_attrs_hash
          c = content_getter cc_id 
          c ||= Content.new :content_config_id=>cc_id, :node=>self
          c.attributes= attrs
          @changed = true if c.text_changed? or c.binary_changed?
          c.save
#          c.update_attributes attrs
        end      
      end
    end  
  
    # -- localized title --
  
    def title
      section.localization == 'mirrored' ? (title_loc||{})[Context.locale] : super
    end
  
    def title=(x)
      if section.localization == 'mirrored'
        self.title_loc ||= {}
        self.title_loc[Context.locale] = x
      else
        super
      end
    end
  
  
    # def initialize(*args)
    #   super *args
    #   raise 'section should be known when doing Node.new'
    # end
  
    # def move_lower
    #   raise 'kokot'
    # end
  
    # def toggle_published!
    #   update_attribute :is_published, !is_published
    # end
    #   
    # def toggle_star!
    #   update_attribute :is_star, !is_star
    # end
  
  
    def fix_positions
      return if ancestry_changed?
    
      # TOOT NEJAK ROZUMNE RIESIT
    
  #    self.position= siblings.where(:section_id=>section_id).size if ancestry_changed?
  #    true
      # index = 1
      # tmp = self_and_siblings.reject{ |x| x.section_name!=section_name or x.configuration_id!=configuration_id }
      # for node in tmp.sort{ |x,y| x.position<=>y.position }
      #   logger.debug "----------- #{node.position} #{node.title}"
      #   node.update_attribute :position, index if node.position != index
      #   index+=1
      # end
    end
  
    # def fix_positions
    #   index = 1
    #   tmp = self_and_siblings.reject{ |x| x.section_name!=section_name or x.configuration_id!=configuration_id }
    #   for node in tmp.sort{ |x,y| x.position<=>y.position }
    #     logger.debug "----------- #{node.position} #{node.title}"
    #     node.update_attribute :position, index if node.position != index
    #     index+=1
    #   end
    # end  
  
  
    def keep_context
      self.site_id = Context.site.id
    end

    # -- wake --
  
    def wake_includes
      { :contents => :content_config }
    end
  
    def wake_destroyable?
      true
    end
    
  end
end