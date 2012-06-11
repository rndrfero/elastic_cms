module Elastic  
  class Master::SitesController < ApplicationController
    
    wake :within_module=>'Elastic'
      
    def edit
      @item.integrity!
      super
    end
    
    def structure_export
      data = YAML::dump @item.tincan_dump('structure')
      send_data data, :filename=>"1Astruct-#{@item.host}-#{Date.today}.yaml"
    end

    def content_export
      data = YAML::dump @item.tincan_dump('content')
      send_data data, :filename=>"1Adata-#{@item.host}-#{Date.today}.yaml"
    end
    
    
    def wake_constraints
      { :master_id=>Context.user.id }
    end
    
          
  end  
end
