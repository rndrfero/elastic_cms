module Elastic
  class Editor::GalleriesController < ApplicationController
  
    wake :within_module=>'Elastic'
    
    before_filter :prepare
    
    def edit
      @item.sync!
      super
    end
    
    # def update
    # end
    
    def f_edit
#      raise @file_record.inspect
      @item.sync!
      edit
    end
    
    def f_update
      @file_record.attributes= params[:file_record]
      if @file_record.save
        flash[:hilite] = "wake.file_record.update_ok"
        @item.sync!        
        redirect_to f_edit_editor_gallery_path(@item,@file_record)
      else
        flash[:error] = "wake.file_record.update_error"
        f_edit
      end
    end
    
    def f_destroy
      # if @file_record.destroy
      #   flash[:hilite] = "wake.file_record.destroy_ok"
      #   redirect_to editor_gallery_path(@item)
      # else
      #   flash[:error] = "wake.file_record.destroy_error"
      #   f_edit
      # end      
    end
      
    def wake_list
      super
      @items = @items.where :site_id=>Context.site.id
    end
    
    private
    def prepare
      # if params[:index]
      #   @index = params[:index].to_i
      #   @filename = @item.files[@index]
      # end
    end
  end

end