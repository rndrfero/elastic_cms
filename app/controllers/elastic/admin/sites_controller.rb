module Elastic
  
  class Admin::SitesController < ApplicationController
    
    wake :within_module=>'Elastic'
      
    def edit
      @item.integrity!
      super
    end
          
  end
  
end
