module Elastic
  
  class Editor::UsersController < ApplicationController
    
    wake :within_module=>'Elastic'

    def update
      params[:user][:password] = nil if params[:user][:password].empty?
      params[:user][:password_confirmation] = nil if params[:user][:password_confirmation].empty?
      super
    end
    
    def wake_list
 #     @items = User.joins(:site) #("INNER JOIN sites ON sites.master_id = users.id")
      super
      
#      raise @items.all.to_yaml
    end
    
    def wake_constraints
      Context.user.master? ? nil : { :site_id=>Context.site.id }
    end
    
  end
  
end
