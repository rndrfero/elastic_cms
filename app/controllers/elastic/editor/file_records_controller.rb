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
    
                
    def prepare
    end
          
  end
end
