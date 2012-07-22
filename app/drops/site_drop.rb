class SiteDrop < Liquid::Drop

  def initialize(x)
    @site = x
  end

  for x in %w{ title index_locale meta_keywords meta_description }
    module_eval "def #{x}; @site.#{x}; end"    
  end
  
  def locales
    @site.locales.map{ |x| x.to_s }
  end
  
  def index_locale
  end

  def sections
    @site.sections.map{ |x| SectionDrop.new(x) }
  end
  
  def galleries
    @site.galleries.map{ |x| GalleryDrop.new(x) }
  end
  
  def section_keys
    @site.sections.map{ |x| x.key }
  end
  
  def index_hash
    ret = {}
    for l in @site.locales.map
      x = @site.index_node l      
      x = NodeDrop.new(x) if x.is_a? Elastic::Node
      ret[l] = x 
    end
    ret
  end
  
  def to_s
    @site.title
  end
  
  def type
    'site'
  end
  
end
