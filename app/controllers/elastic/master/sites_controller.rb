module Elastic  
  class Master::SitesController < ApplicationController
    
    wake :within_module=>'Elastic'
      
    def edit
      @item.integrity!
      super
    end
    
    def wake_constraints
      { :master_id=>Context.user.id }
    end
    
          
  end  
end
