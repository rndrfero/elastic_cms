module Elastic
  class Master::SectionsController < ApplicationController
    
    before_filter :ensure_ownership
  
    wake :within_module=>'Elastic'
    
    def wake_list
      params[:order] ||= 'position'
      super
    end
    

    def toggle_star
      @item.toggle_star!
      flash[:hilite] = 'cms_backend.simply_yes'
      redirect_to :back
    end

    def toggle_hidden
      @item.toggle_hidden!
      flash[:hilite] = 'cms_backend.simply_yes'
      redirect_to :back
    end

    def toggle_locked
      @item.toggle_locked!
      flash[:hilite] = 'cms_backend.simply_yes'
      redirect_to :back
    end

    def toggle_pin
      @item.toggle_pin!
      flash[:hilite] = 'cms_backend.simply_yes'
      redirect_to :back
    end

    def move_higher
      @item.move_higher
      flash[:hilite] = 'cms_backend.simply_yes'
      redirect_to :back
    end

    def move_lower
      @item.move_lower
      flash[:hilite] = 'cms_backend.simply_yes'
      redirect_to :back
    end

  
    def new_content_config
      @item.content_configs << ContentConfig.new
      render :action=>'section_form'
    end
  
    def cc_toggle_published
      @content_config.toggle_published!
      flash[:hilite] = 'cms_backend.simply_yes'
      render :action=>'section_form'
    end
    
    def cc_zap
      @content_config.contents.map{ |x| x.destroy }
      flash[:hilite] = 'cms_backend.simply_yes'
      raise 'jebe?'
      redirect_to :back
    end
  
    def wake_constraints
      {:site_id=>Context.site.id}
    end

  end
end