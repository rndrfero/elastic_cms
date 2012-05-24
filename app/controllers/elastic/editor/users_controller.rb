module Elastic
  
  class Editor::UsersController < ApplicationController
    
    wake :within_module=>'Elastic'
    
    def wake_constraints
      { :site_id=>Context.site.id }
    end
    
  end
  
end
