class GalleryDrop < Liquid::Drop

  def initialize(x)
    @gallery = x
  end

  for x in %w{ title path is_star? }
    module_eval "def #{x}; @gallery.#{x}; end"    
  end
  
  def files
    @gallery.file_records.map{ |x| FileRecordDrop.new x }
  end
  
  def images
    @gallery.file_records.images.map{ |x| FileRecordDrop.new x }
  end

  def non_images
    @gallery.file_records.non_images.map{ |x| FileRecordDrop.new x }
  end
  # 
  # def starry_images
  #   @gallery.file_records.starry.images.map{ |x| FileRecordDrop.new x }
  # end
  
  def to_s
    @gallery.title
  end
  
end
