#require_dependency 'strip_diacritic'
require 'iconv'

module Elastic
  class Node < ActiveRecord::Base
    include WithKey
    extend WithToggles

    has_paper_trail :ignore => [:title, :locale, :is_star, :is_published, :is_locked, :parent_id, :position, :redirect, :published_version_id]
    
    attr_accessible :section, :locale, :title, :key, :is_published, :is_star, :parent_id, :position, :contents_setter, :redirect, :published_at
  
    serialize :title_loc
  
    has_many :contents, :dependent=>:destroy
    belongs_to :section
    belongs_to :site
    belongs_to :published_version, :class_name=>'Version', :foreign_key=>'published_version_id'    
  
    #accepts_nested_attributes_for :contents
  
    has_ancestry :cache_depth =>true
    acts_as_list :scope=>'section_id = #{section_id} AND #{ancestry ? "ancestry = \'#{ancestry}\'" : \'ancestry IS NULL\'}'
  
    validates_presence_of :title, :section, :key
#    validates_format_of :key, :with=>/^[a-zA-Z0-9\-_]*$/
    validates_uniqueness_of :key, :scope=>:site_id
    validates_inclusion_of :locale, :in=>lambda{ |x| x.site.locales }, :if=>lambda{ |x| x.section.localization=='free' }
    validates_presence_of :published_at, :if=>lambda{ |x| x.section.form == 'blog' }
  
    before_validation :generate_key
    before_validation :keep_context
    before_save :inc_version_cnt
    before_destroy :wake_destroyable?

  
    scope :published, where(:is_published=>true).order('ancestry_depth,position DESC')
    scope :roots, where(:ancestry=>nil).order('ancestry_depth,position DESC')
    scope :localized, lambda { where(:locale=>Context.locale) }
    scope :tree_ordered, :order=>"ancestry_depth,position DESC"
    scope :date_ordered, :order=>"published_at"
#    .section.form=='blog' ? reorder("published_at") : reorder("ancestry_depth,position DESC"
    scope :starry, where(:is_star=>true)
    scope :in_public, lambda { includes(:contents=>:content_config).where(:site_id=>Context.site.id) }
    
    with_toggles :star, :locked, :published
  
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
          @changed = true if c.text_changed? # or c.binary_changed?
          c.save
        end
      else
        for cc_id, attrs in cc_id_to_attrs_hash
          c = content_getter cc_id 
          c ||= Content.new :content_config_id=>cc_id, :node=>self
          c.attributes= attrs
          @changed = true if c.text_changed? # or c.binary_changed?
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
    
    def publish_version!(the_version)
      self.update_attribute :published_version_id, the_version.id
      timestamp = the_version.created_at
      for c in contents
        the_c = c.version_at(timestamp)
        c.update_attribute :published_text, the_c.text
#        raise c.published_text.inspect
      end
#      contents true
#      self.save!
#      raise self[:published_version_id].inspect
#      raise self.published_version.inspect
    end
    
    def publish_recent!
      self.published_version = nil
      for c in contents
        c.update_attribute :published_text, nil
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
  
    
    def keep_context
      self.site_id = Context.site.id
      self.locale = Context.locale if section.localization == 'free' if locale.blank?
    end

    # -- wake --
  
    def wake_includes
      { :contents => :content_config }
    end
  
    def wake_destroyable?
      children.empty? and !is_locked?
    end
    
  end
end