class ContentDrop < Liquid::Drop

  def initialize(x)
    @content = x
  end
  
  # for x in %w{ text binary }
  #   module_eval "def #{x}; @content.#{x}; end"    
  # end  
  
  def text
    if Elastic::Context.user and @content.content_config.is_live?
      Elastic::Context.ctrl.send :render_to_string, :partial=>'/elastic/public/live_content',
        :locals=>{:content=>@content, :content_config=>@content.content_config}
    else
      Elastic::Context.user ? @content.text : (@content.published_text||@content.text)
    end
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