module Elastic  
  class Master::SitesController < ApplicationController
    
    wake :within_module=>'Elastic'
    
    # def uniq_star
    #   @item.uniq_star!
    #   flash[:hilite] = 'cms_backend.simply_yes'
    #   redirect_to :back
    # end

    def toggle_star
      @item.toggle_star!
      flash[:hilite] = 'cms_backend.simply_yes'
      redirect_to :back
    end
    
    def clean
      Site.clean!
      flash[:hilite] = 'cms_backend.simply_gone'
      redirect_to :back
    end

    def zap
      @item.zap!
      flash[:hilite] = 'cms_backend.simply_gone'
      redirect_to :back
    end
      
    def edit
      @item.integrity!
      super
    end
    
    def toggle_reload_theme
      @item.toggle_reload_theme!
      flash[:hilite] = 'cms_backend.simply_yes'
      redirect_to :back
    end
    
    def copy_themes
      @item.copy_themes!
      flash[:hilite] = 'cms_backend.simply_yes'
      redirect_to :back
    end
    
    def export_structure
      data = @item.export('structure')
      send_data data, :filename=>"-#{@item.host}-#{@item.theme}.structure.tar"
    end

    def export_content
      data = @item.export('content')
      send_data data, :filename=>"-#{@item.host}-#{@item.theme}.content.tar"
    end
    
    def import
        raise 'No file uploaded.' unless params[:site] and params[:site][:import]
        x = params[:site][:import]
        if x.original_filename =~ /structure.tar/
          @item.import! 'structure', x.tempfile.read
        elsif x.original_filename =~ /content.tar/
          @item.import! 'content', x.tempfile.read
        else
          raise "Cannot quess from filename if its structure or content."
        end
        
      begin
      rescue Exception=>e
        flash[:error] = e.message
      else
        flash[:hilite] = 'cms_backend.simply_yes'
      end
      redirect_to master_site_path @item
    end
    
    def reload_structure
    #   begin
    #   rescue Exception=>e
    #     flash[:error] = e.msg
    #     redirect_to master_site_path @item
    #   end
    end
    
    def reload_content
    end
    
    
    def wake_constraints
      { :master_id=>Context.user.id }
    end
    
          
  end  
end
