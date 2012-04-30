class ContentDrop < Liquid::Drop

  def initialize(x)
    @content = x
  end
  
  for x in %w{ key text binary }
    module_eval "def #{x}; @content.#{x}; end"    
  end  
  
  def form
    @content.content_config.form
  end
  
  def meta
    @content.content_config.meta
  end

  def to_s
    if %w{ textfield textarea }.include? @content.content_config.form 
      @content.text
    end
  end
  
end