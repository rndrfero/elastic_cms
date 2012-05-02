module Elastic
  class Gallery < ActiveRecord::Base
    include Elastic::WithDirectory
    
    META = %w{ img_w img_h img_process tna_w tna_h tna_process tnb_w tnb_h tnb_process }

    REGEXP_IMAGE = Regexp.new('.*\.(jpg|jpeg|png|gif)$', Regexp::IGNORECASE)
    REGEXP_ZIP = Regexp.new('.*\.zip$', Regexp::IGNORECASE)
    REGEXP_SWF = Regexp.new('.*\.swf$', Regexp::IGNORECASE)
    
    attr_accessible :title, :ident, :is_star, :is_watermarked, :meta
    serialize :meta
    
    belongs_to :site
    
    validates_presence_of :title, :site_id
#    validates_format_of :key, :allow_blank=>true, :with=>/^[a-z]*$/
    
    before_validation :keep_context
    after_save :integrity!
    
    def dir
      File.join site.home_dir, "galleries", "#{id}-#{key.blank? ? 'untitled' : key}"
    end
    
    def integrity!
      create_or_rename_dir! dir
      for x in %w{ orig img tna tnb }
        FileUtils.mkdir_p File.join(dir,x)
      end
    end
    
    def files
      Dir.entries(File.join(dir,'orig')).reject!{ |x| x.starts_with? '.' }
    end
    
    def images
      files.select { |x| x=~REGEXP_IMAGE }||[]
    end
    
    def non_images
      files - images
    end
    
    
    def file=(x)
      FileUtils.cp x.tempfile.path, File.join(dir,'orig',x.original_filename)
    end
    
    def keep_context
      self.site_id = Context.site.id
    end
    
    # -- wake --
    
    def wake_includes
      []
    end
  
    def wake_destroyable?
      true
    end
    
  end
end
