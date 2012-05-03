module Elastic
  class FileRecord < ActiveRecord::Base
    include Elastic::ThumbnailGenerators
    
    REGEXP_IMAGE = Regexp.new('.*\.(jpg|jpeg|png|gif)$', Regexp::IGNORECASE)
    REGEXP_ZIP = Regexp.new('.*\.zip$', Regexp::IGNORECASE)
    REGEXP_SWF = Regexp.new('.*\.swf$', Regexp::IGNORECASE)
    
    scope :images, where("filename REGEXP ?", '.*\.(jpg|jpeg|png|gif)$')
    scope :non_images, where("filename NOT REGEXP ?", '.*\.(jpg|jpeg|png|gif)$')
    
    attr_accessible :title, :text, :filename, :ino, :gallery_id    
    belongs_to :gallery
    
    validates_presence_of :gallery
    #validates_format_of :filename, :with=>/^[a-zA-Z0-9\-._ ]*$/
    
    before_validation :saturate
    before_save :rename_files!
    after_create :process!
    after_destroy :remove_files!
        
    def is_image?
      filename =~ REGEXP_IMAGE
    end
        
    def path(which='orig')
      File.join gallery.path, which, filename
    end
    
    def rename_files!
      return if not filename_changed? # not changed at all
      return if new_record? 
#      return if not File.exists? File.join(gallery.path, 'orig', filename_was) # problem is elsewhere (syncing)
        
#      File.rename *filename_change.map!{ |x| File.join(gallery.path, 'orig', x) }
      
      for which in %w{ orig img tna tnb }
        next if not File.exists? File.join(gallery.path, which, filename_was)
#        raise filename_change.inspect
#          raise filename_change.map!{ |x| File.join(gallery.path, which, x) }.inspect
        File.rename *filename_change.map!{ |x| File.join(gallery.path, which, x) }
      end

    end  
    
    def remove_files!
      for which in %w{ orig img tna tnb }
        FileUtils.remove_entry_secure path(which) if File.exists? path(which) 
      end      
    end
    
    # :force => true
    def process!(options={})
      return if not is_image?
      Elastic.logger.debug "Elastic CMS: FileRecord.process! for #{path}"
      for v in Gallery::VARIANTS
        w = gallery.get_meta(v,'w').to_i
        h = gallery.get_meta(v,'h').to_i
        p = gallery.get_meta(v,'p')
      
        w = nil if w<=0
        h = nil if h<=0
        p = nil if p.blank?
        
        if not File.exists? path(v) or options[:force]
           # we have to copy           
          if (w and h) or p
             FileUtils.cp path('orig'), path(v) 
          end
          # we have to generate thumbnails
          if w and h            
#            raise "#{w} #{h}"
            gallery_tn path(v), path(v), w, h 
          end
          # we have to process them
          raise 'TODO' if p
        end
      end      
    end  
    
    def saturate
      filename.gsub!(/^.*(\\|\/)/, '')
#      \ / : * ? " <> |
      filename.gsub!(/[\*\:\?\"\<\>\|]*/,'')
    end
    
    
    # def fix_ino!
    #   # when there is a file and ino is OK, thats good
    #   the_ino = File.stat(path).ino
    #   update_attribute :ino, the_ino if the_ino!=ino
    # end
    
  end
end