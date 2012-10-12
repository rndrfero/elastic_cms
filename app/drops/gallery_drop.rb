class GalleryDrop < Liquid::Drop

  def initialize(x)
    @gallery = x
#    Elastic::Context.ctrl.add_reference @gallery
  end

  for x in %w{ title path is_star? }
    module_eval "def #{x}; @gallery.#{x}; end"    
  end
  
  def title_file_record
    @gallery.title_file_record ? FileRecordDrop.new(@gallery.title_file_record) : nil
  end  
  alias :title_image :title_file_record
  
  def files
    @gallery.file_records.map{ |x| FileRecordDrop.new x }
  end
  
  def images
    @gallery.file_records.images.map{ |x| FileRecordDrop.new x }
  end

  def non_images
    @gallery.file_records.non_images.map{ |x| FileRecordDrop.new x }
  end
  

  def images_paths_orig
    @gallery.file_records.images.map{ |x| x.path(:orig) }
  end
    
  def images_paths_img
    @gallery.file_records.images.map{ |x| x.path(:img) }
  end
  
  def images_paths_tna
    @gallery.file_records.images.map{ |x| x.path(:tna) }
  end
  
  def images_paths_tnb
    @gallery.file_records.images.map{ |x| x.path(:tnb) }
  end
  

  # def starry_images
  #   @gallery.file_records.starry.images.map{ |x| FileRecordDrop.new x }
  # end
  
  def to_s
    @gallery.title
  end
  
end
