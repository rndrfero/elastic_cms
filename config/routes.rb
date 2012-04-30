Elastic::Engine.routes.draw do
  
  scope "/:locale" do  
  
    namespace 'admin' do
      resources :sites
      
      resources :sections do
        get 'new_content_config', :on=>:member
        get 'cc_toggle_published/:content_config_id', :on=>:member, :action=>'cc_toggle_published'
        # get 'cc_move_higher/:content_config_id', :on=>:member, :action=>'cc_move_higher'                 
        # get 'cc_move_lower/:content_config_id', :on=>:member, :action=>'cc_move_higher'                 
        
        resources :nodes do
          resources :contents
          post 'toggle_published', :on=>:member
          post 'toggle_star', :on=>:member
          post 'move_higher', :on=>:member
          post 'move_lower', :on=>:member
        end      
        
      end
      
    end
  end
  
end
