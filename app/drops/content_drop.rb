class ContentDrop < Liquid::Drop

  def initialize(x)
    @content = x
  end
  
  # for x in %w{ text binary }
  #   module_eval "def #{x}; @content.#{x}; end"    
  # end  
  
  def text
    Elastic::Context.user ? @content.text : (@content.published_text||@content.text)
  end
  
  def form
    @content.content_config.form
  end
  
  def meta
    @content.content_config.meta
  end
  
  def to_s
    text
    # if %w{ textfield textarea select image }.include? @content.content_config.form 
    #   text
    # end
  end
  
end