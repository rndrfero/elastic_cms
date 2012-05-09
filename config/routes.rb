Elastic::Engine.routes.draw do
  
  match '/auth/:provider/callback', :to => 'sessions#create'
  match '/logout', to: 'sessions#destroy'  
  
  # -- frontend --

  root :to => 'elastic#index'
  
  match '/x/*filepath' => 'elastic#static' #, :as=>'static'
  match '/data/*filepath' => 'elastic#data' #, :as=>'data'
  match '/404' => 'elastic#not_found'# , :as=>'not_found'
  
  match '/:locale' => 'elastic#index'
  match '/:locale/show/:key' => 'elastic#show'
  match '/:locale/section/:key' => 'elastic#section'
  match '/:locale/access_denied' => 'elastic#access_denied', :as=>'access_denied'
  
  # -- backend --
  
  scope "/:locale" do  
  
    namespace 'admin' do
      resources :sites      
      resources :sections do
        get 'new_content_config', :on=>:member
        get 'cc_toggle_published/:content_config_id', :on=>:member, :action=>'cc_toggle_published', :as=>'cc_toggle_published'
        # get 'cc_move_higher/:content_config_id', :on=>:member, :action=>'cc_move_higher'                 
        # get 'cc_move_lower/:content_config_id', :on=>:member, :action=>'cc_move_higher'                         
      end      
    end
    
    namespace 'editor' do      
      resources :sections do
        resources :nodes do
          resources :contents
          post 'toggle_published', :on=>:member
          post 'toggle_star', :on=>:member
          post 'move_higher', :on=>:member
          post 'move_lower', :on=>:member
        end      
      end
      resources :galleries do
        get 'f_destroy', :on=>:member, :action=>'f_destroy', :as=>'f_destroy'
        get 'f_edit/:file_record_id', :on=>:member, :action=>'f_edit', :as=>'f_edit'
        put 'f_update/:file_record_id', :on=>:member, :action=>'f_update', :as=>'f_update'
      end
    end
      
  end
  
end
