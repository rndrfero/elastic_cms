class SiteDrop < Liquid::Drop

  def initialize(x)
    @site = x
  end

  for x in %w{ title }    
    module_eval "def #{x}; @site.#{x}; end"    
  end
  
  def locales
    @site.locales.map{ |x| x.to_s }
  end

  def sections
#    return @site.sections.size.to_s
    @site.sections.map{ |x| SectionDrop.new(x) }
  end
  
  def galleries
    @site.galleries.map{ |x| GalleryDrop.new(x) }
  end
  
  def section_keys
    @site.sections.map{ |x| x.key }
  end
  
  def index_hash
    # ret = {}
    # for k, v in @site.locale_to_index_hash
    #   @site.nodes.where(:)
    #   ret[k] = v
    # end
    # ret
  end
  
  def to_s
    @site.title
  end
  
  def type
    'site'
  end
  
end
