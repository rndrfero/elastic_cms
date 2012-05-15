module Elastic
  class Master::SectionsController < ApplicationController
  
    wake :within_module=>'Elastic'

  #  def new
  #    @item = Section.new :site=>CurrentContext.site
  #    super
  #  end

    def wake_list
      super
      @items = @items.where :site_id=>Context.site.id
    end
  
    def new_content_config
      @item.content_configs << ContentConfig.new
      render :action=>'section_form'
    end
  
    def cc_toggle_published
      @content_config.toggle_published!
      render :action=>'section_form'
    end
  

  end
end