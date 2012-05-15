Elastic::Engine.routes.draw do
  
  match '/auth/:provider/callback', :to => 'sessions#create'
  match '/logout', to: 'sessions#destroy'  
  
  # -- frontend --

  root :to => 'elastic#index'
  
  match '/x/*filepath' => 'elastic#static' #, :as=>'static'
  match '/404' => 'elastic#not_found'# , :as=>'not_found'
  
  match '/:locale' => 'elastic#index'
  match '/:locale/show/:key' => 'elastic#show'
  match '/:locale/section/:key' => 'elastic#section'
  match '/:locale/access_denied' => 'elastic#access_denied', :as=>'access_denied'
  
  # -- backend --
  
  scope "/:locale" do
    
    namespace 'admin' do
      resource :configuration
      # zalohovanie celeho systemu
    end
  
    namespace 'master' do
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
          post 'toggle_published', :on=>:member
          post 'toggle_star', :on=>:member
          post 'toggle_hidden', :on=>:member
          post 'toggle_locked', :on=>:member
          post 'move_higher', :on=>:member
          post 'move_lower', :on=>:member
          
          resources :contents
        end      
      end
      resources :galleries do
        post 'toggle_star', :on=>:member
        post 'toggle_hidden', :on=>:member
        post 'toggle_locked', :on=>:member
        post 'regenerate', :on=>:member
        
        get 'f_destroy', :on=>:member, :action=>'f_destroy', :as=>'f_destroy'
        # get 'f_edit/:file_record_id', :on=>:member, :action=>'f_edit', :as=>'f_edit'
        # put 'f_update/:file_record_id', :on=>:member, :action=>'f_update', :as=>'f_update'
        resources :file_records
      end
      resource :site do
        post 'import'
        post 'export'
      end      
    end
      
  end
  
end
