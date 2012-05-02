module Elastic
  class Gallery < ActiveRecord::Base
    include Elastic::WithDirectory
    
    META = %w{ img_w img_h img_process tna_w tna_h tna_process tnb_w tnb_h tnb_process }
    
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
      for x in %w{ img tna tnb }
        FileUtils.mkdir_p File.join(dir,x)
      end
    end
    
    def file=(x)
#      raise x.tempfile.inspect
      FileUtils.cp x.tempfile.path, File.join(dir,x.original_filename)
      # dest = 
      # tmp.path
      # file = File.join("public", params[:file_upload][:my_file].original_filename)
      # tmp = params[:file_upload][:my_file].tempfile
      # file = File.join("public", params[:file_upload][:my_file].original_filename)
      # File.cp tmp.path, file
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
