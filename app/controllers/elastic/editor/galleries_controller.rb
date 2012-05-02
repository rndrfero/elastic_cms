module Elastic
  class Editor::GalleriesController < ApplicationController
  
    wake :within_module=>'Elastic'
    

    def wake_list
      super
      @items = @items.where :site_id=>Context.site.id
    end
  end

end