module Elastic  
  class Editor::FileRecordsController < ApplicationController
    
    wake :within_module=>'Elastic'
    
    before_filter :prepare

    # def edit
    #   flash.now[:notice] = "wake.#{_ident}.edit"
    #   respond_to do |format|
    #     format.html { render :action => _ident+'_form' } #
    #     format.js { render :template=>'/wake/form' }
    #   end
    # end
    
    def index
      redirect_to editor_gallery_path(@gallery)
    end
    
    def show
      if @item.is_image?
      else
        send_file @item.filepath, :filename=>@item.filename
      end
    end
    
    def toggle_star
      @item.toggle_star!
#      raise @item.to_yaml
      render_update
    end
    
    private
    
    def render_update
      respond_to do |format|
        format.js do
          flash.now[:hilite] = "wake.#{_ident}.update_ok"
          render :template => '/wake/update'
        end
      end
    end
      
    
                
    def prepare
    end
          
  end
end
