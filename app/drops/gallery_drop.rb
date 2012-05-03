class GalleryDrop < Liquid::Drop

  def initialize(x)
    @gallery = x
  end

  for x in %w{ title files images non_images }    
    module_eval "def #{x}; @gallery.#{x}; end"    
  end  
  
  def path
    '/galleries/'+@gallery.dir
  end

  def to_s
    @gallery.title
  end
  
end
