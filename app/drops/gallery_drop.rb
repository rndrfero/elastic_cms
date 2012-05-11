class GalleryDrop < Liquid::Drop

  def initialize(x)
    @gallery = x
  end

  for x in %w{ title files images non_images file_records }
    module_eval "def #{x}; @gallery.#{x}; end"    
  end
  
  def fr_images
    @gallery.file_records.images.map{ |x| FileRecordDrop.new x }
  end

  def fr_non_images
    @gallery.file_records.non_images.map{ |x| FileRecordDrop.new x }
  end
  
  def path
    '/galleries/'+@gallery.dir
  end

  def to_s
    @gallery.title
  end
  
end
