module Elastic
  
  class Editor::SitesController < ApplicationController
    
    wake :within_module=>'Elastic'
    
    before_filter :prepare
      
    def edit
      @item.integrity!
      super
    end
    
    def prepare
      @item = Context.site
    end
          
  end
  
end
