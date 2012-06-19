module Elastic
  class Editor::GalleriesController < ApplicationController
  
    wake :within_module=>'Elastic'
    
    before_filter :prepare
    after_filter :wake_referer_params
    before_filter :ensure_ownership
    
    def edit
      @item.sync!
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
    
    def regenerate
      @item.process! :force=>true
      flash[:hilite] = 'cms_backend.simply_yes'
      redirect_to :back
    end
          
    def f_destroy
      indexes = (params[:index]||[]).map!{ |x| x.to_i }
      for fr in @item.file_records
        fr.destroy if indexes.include? fr.id 
      end
      redirect_to editor_gallery_path(@item)      
    end

    def f_star
      indexes = (params[:index]||[]).map!{ |x| x.to_i }
      for fr in @item.file_records
        fr.toggle_star! if indexes.include? fr.id 
      end
      redirect_to editor_gallery_path(@item)      
    end

      
    # def wake_list
    #   super
    #   @items = @items.where :site_id=>Context.site.id
    # end


    def wake_constraints
      {:site_id=>Context.site.id}
    end
    
    private
    def prepare
    end
    
  end

end


# if @file_record.destroy
#   flash[:hilite] = "wake.file_record.destroy_ok"
#   redirect_to editor_gallery_path(@item)
# else
#   flash[:error] = "wake.file_record.destroy_error"
#   f_edit
# end      


# if params[:index]
#   @index = params[:index].to_i
#   @filename = @item.files[@index]
# end


#     def f_edit
# #      raise @file_record.inspect
#       @item.sync!
#       edit
#     end
#     
#     def f_update
#       @file_record.attributes= params[:file_record]
#       if @file_record.save
#         flash[:hilite] = "wake.file_record.update_ok"
#         @item.sync!        
#         redirect_to f_edit_editor_gallery_path(@item,@file_record)
#       else
#         flash[:error] = "wake.file_record.update_error"
#         f_edit
#       end
#     end
#     
