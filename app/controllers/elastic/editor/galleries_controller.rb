module Elastic
  class Editor::GalleriesController < ApplicationController
  
    wake :within_module=>'Elastic'
    
    before_filter :prepare
    
    def f_edit
      edit
    end
    
    def f_update
      edit
    end
    
    def f_destroy
      edit
    end
      
    def wake_list
      super
      @items = @items.where :site_id=>Context.site.id
    end
    
    private
    def prepare
      if params[:index]
        @index = params[:index].to_i
        @filename = @item.files[@index]
      end
    end
  end

end