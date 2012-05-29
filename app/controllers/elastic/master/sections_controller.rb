module Elastic
  class Master::SectionsController < ApplicationController
    
    before_filter :ensure_ownership
  
    wake :within_module=>'Elastic'

    def toggle_star
      @item.toggle_star!
      flash[:hilite] = 'simply_yes'
      redirect_to :back
    end

    def toggle_hidden
      @item.toggle_hidden!
      flash[:hilite] = 'simply_yes'
      redirect_to :back
    end

    def toggle_locked
      @item.toggle_locked!
      flash[:hilite] = 'simply_yes'
      redirect_to :back
    end

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