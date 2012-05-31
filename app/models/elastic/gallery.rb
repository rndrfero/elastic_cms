require_dependency 'elastic/thumbnail_generators'

module Elastic
  class Gallery < ActiveRecord::Base
    include WithDirectory
    include WithKey
    include ThumbnailGenerators
    extend WithToggles
    
    VARIANTS = %w{ img tna tnb }
    META = %w{ w h efx params }
    
    attr_accessible :title, :key, :is_star, :is_watermarked, :meta, :file, :is_timestamped, :site_id, :is_dependent, :is_hidden #, :file_records_attributes
    serialize :meta
    
    belongs_to :site
    has_many :file_records
    alias :frs :file_records
#    accepts_nested_attributes_for :file_records
    
    validates_presence_of :title, :site_id
    validates_uniqueness_of :key, :scope=>:site_id
    
#    before_validation :keep_context
    before_validation :saturate
    before_validation :generate_key
    after_save :integrity!
    
    after_save(:if=>lambda{ |x| x.meta_changed? }) { process! :force=>true}
    
    with_toggles :star, :locked, :hidden, :watermarked    
    
    
    scope :starry, where(:is_star=>true)
    
    
    
    def dir(the_key=key)
      "#{the_key.blank? ? "#{id}-untitled" : the_key}"
    end

    def filepath(the_key=key)
      File.join site.home_dir, "galleries", dir(the_key)
    end
    
    def path
#      "#{site.path}/galleries/#{dir}"
      "/x/galleries/#{dir}"
    end
        
    def integrity!
      if dir != dir(key_was) and File.exists? filepath(key_was)
        FileUtils.mv filepath(key_was), filepath
      end      
#      create_or_rename_dir! filepath            
      for x in %w{ orig img tna tnb }
        FileUtils.mkdir_p File.join(filepath,x)
      end
    end
        
    def sync!
      Elastic.logger_info "Gallery.sync! for #{dir}"
      integrity!
      for f in files
        ino = File.stat(File.join(filepath,'orig',f)).ino
        fr = file_records.where(:filename=>f).first
        if fr        
          fr.update_attribute :ino, ino
        else
          fr = file_records.where(:ino=>ino).first
          if fr
            fr.update_attribute :filename, f
          else
            file_records.create!(:filename=>f, :ino=>ino)
          end
        end
          
        # new file - somebody renamed?
        # new file - create record
      end
      # remove non-valid records
      for fr in file_records
        fr.destroy if not File.exists?(fr.filepath)
      end  
      file_records.reload
    end
    
    
    def files
      Dir.entries(File.join(filepath,'orig')).reject!{ |x| x.starts_with? '.' }
    end
    
    def images
      files.select { |x| x=~FileRecord::REGEXP_IMAGE }||[]
    end
    
    def non_images
      files - images
    end

    def is_master?
      id == site.master_gallery_id
    end
    
    def get_meta(variant,meta_attr)
      return site.master_gallery.get_meta(variant,meta_attr) if is_dependent? and site.master_gallery and site.master_gallery!=self
      variant, meta_attr = variant.to_s, meta_attr.to_s
      ret = ((meta||{})[variant]||{})[meta_attr]
      ret = nil if ret.blank?
      ret
    end
    
    def has_variant?(variant)
      get_meta(variant,:w) and get_meta(variant,:h)
    end
        
    def process!(options={})
      for x in file_records.images
        x.process! options
      end
    end
        
    # # rebuild all image variants
    # def process!(options={})
    #   for v in Gallery::VARIANTS
    #     w = get_meta(v,'w').to_i
    #     h = get_meta(v,'h').to_i
    #     p = get_meta(v,'p')
    #     
    #     w = nil if w<=0
    #     h = nil if h<=0
    #     p = nil if p.blank?
    #     
    #     if (w and h) or p # we have to copy
    #       for fr in file_records.images
    #         File.cp fr.filepath('orig'), fr.filepath(v)
    # 
    #         if (w and h) # we have to generate thumbnails
    #           gallery_tn fr.filepath(v), fr.filepath(v), w, h
    #         end
    #         
    #         if p # we have to process them
    #           raise 'TODO'
    #         end
    #       end
    #     end
    #   end      
    # end
    
        
    def file=(x)
      FileUtils.cp x.tempfile.path, File.join(filepath,'orig',x.original_filename)
      sync!
    end
            
    def saturate
      self.is_dependent = true if new_record?
      self.meta = {} if not meta
      for v in VARIANTS
        self.meta[v] = {} if not self.meta[v]
        for m in META
          self.meta[v][m] = nil if self.meta[v].blank?
        end
      end
    end
    
    # -- wake --
    
    def wake_includes
      []
    end
  
    def wake_destroyable?
      file_records.empty?
    end
    
  end
end
