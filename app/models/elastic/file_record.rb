module Elastic
  class FileRecord < ActiveRecord::Base
    include Elastic::ThumbnailGenerators
    extend WithToggles
    
    REGEXP_IMAGE = Regexp.new('.*\.(jpg|jpeg|png|gif)$', Regexp::IGNORECASE)
    REGEXP_ZIP = Regexp.new('.*\.zip$', Regexp::IGNORECASE)
    REGEXP_SWF = Regexp.new('.*\.swf$', Regexp::IGNORECASE)
        
    attr_accessible :title, :text, :filename, :ino, :gallery_id, :basename, :extname
    belongs_to :gallery
    
    with_toggles :star
    
    # -- validations --
    
    validates_presence_of :gallery_id
    validates_presence_of :filename
    #validates_format_of :filename, :with=>/^[a-zA-Z0-9\-._ ]*$/
    
    before_validation :saturate
    before_save :rename_files!
    after_create :process!
    after_destroy :remove_files!
    
    # -- scopes --
    
    scope :images, where("filename REGEXP ?", '.*\.(jpg|jpeg|png|gif)$')
    scope :non_images, where("filename NOT REGEXP ?", '.*\.(jpg|jpeg|png|gif)$')
    scope :starry, where(:is_star=>true)

    # -- methods --
        
    def is_image?
      filename =~ REGEXP_IMAGE
    end
        
    def filepath(which='orig')
      File.join gallery.filepath, which.to_s, filename
    end
    
    def path(which='orig')
      File.join gallery.path, which.to_s, filename
    end
    
    def image_ok?(which)
      File.exists?(filepath which)
    end
    
    def basename
      filename.chomp extname
    end
    
    def extname
      File.extname filename
    end
    
    def basename=(x)
      self.filename = x+extname
    end
    
    def extname=(x)
      self.filename = basename+x
    end
    
    # title file records
    def is_title?
      gallery.title_file_record_id == self.id
    end
    
    def set_title!
      gallery.update_attribute :title_file_record_id, self.id
    end

    def toggle_title!
      gallery.update_attribute :title_file_record_id, (is_title? ? nil : self.id)
    end
    
    def key
      filename
    end
    
    # def images_ok?(which)
    # end
    # 
    # def size
    #   File.size(filepath)
    # end
    
    def rename_files!
      return true if not filename_changed? # not changed at all
      return true if new_record? 
#      return if not File.exists? File.join(gallery.path, 'orig', filename_was) # problem is elsewhere (syncing)
        
#      File.rename *filename_change.map!{ |x| File.join(gallery.path, 'orig', x) }
      
      for which in %w{ orig img tna tnb }
        next if not File.exists? File.join(gallery.filepath, which, filename_was)
#        raise filename_change.inspect
#          raise filename_change.map!{ |x| File.join(gallery.path, which, x) }.inspect
        File.rename *filename_change.map!{ |x| File.join(gallery.filepath, which, x) }
      end
      return true 
    end  
    
    def remove_files!
      for which in %w{ orig img tna tnb }
        FileUtils.remove_entry_secure filepath(which) if File.exists? filepath(which) 
      end      
    end
    
    # :force => true
    def process!(options={})
      return if not is_image?
      Rails.logger.debug "Elastic CMS: FileRecord.process! for #{path}"
      for v in %w{ img tna tnb }
        w = gallery.get_meta(v,'w').to_i
        h = gallery.get_meta(v,'h').to_i
        efx = gallery.get_meta(v,'efx')
        params = gallery.get_meta(v,'params')
      
        w = nil if w<=0
        h = nil if h<=0
        efx = nil if efx.blank?
        
        if not File.exists? path(v) or options[:force]
           # we have to copy           
          if (w and h) or p
             FileUtils.cp filepath('orig'), filepath(v) 
          end
          # we have to generate thumbnails
          if w and h            
#            raise "#{w} #{h}"
            if v == 'img'
              max_tn filepath(v), filepath(v), w, h 
            else
              gallery_tn filepath(v), filepath(v), w, h 
            end
          end
          # we have to process them
#            Efx.process! filepath(v), filepath(v), 'sepia', :intensity=>2
          if efx
            the_efx = Efx.new efx, params            
            the_efx.process! filepath(v), filepath(v) if the_efx.valid? 
          end
        end
      end      
    end  
    
    def saturate
      filename.gsub!(/^.*(\\|\/)/, '')
#      \ / : * ? " <> |
      filename.gsub!(/[\*\:\?\"\<\>\|]*/,'')
      true
    end
    
    
    # def fix_ino!
    #   # when there is a file and ino is OK, thats good
    #   the_ino = File.stat(path).ino
    #   update_attribute :ino, the_ino if the_ino!=ino
    # end
    
  end
end