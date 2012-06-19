Elastic::Engine.routes.draw do
      
  # -- frontend --

  root :to => 'elastic#index'
  
  match '/x/*filepath' => 'elastic#static' #, :as=>'static'
  match '/404' => 'elastic#not_found'# , :as=>'not_found'

  match "/login" => redirect("/users/sign_in")  
  match "/logout" => redirect("/users/sign_out")  

  
  match '/:locale' => 'elastic#index'
  match '/:locale/show/:key' => 'elastic#show', :as=>'show'
  match '/:locale/section/:key' => 'elastic#section', :as=>'section'  

  # filesystem construction style
  match '/:locale/l/*filepath' => 'elastic#liquid', :as=>'liquid'
  
  # edit in show
  match '/:locale/edit/:content_id' => 'elastic#edit', :as=>'edit_index'
  post '/:locale/update/:content_id' => 'elastic#edit', :as=>'update_index'

  # edit in show
  match '/:locale/show/:key/edit/:content_id' => 'elastic#edit', :as=>'edit_show'
  post '/:locale/show/:key/update/:content_id' => 'elastic#update', :as=>'update_show'

  # edit in section
  match '/:locale/section/:key/edit/:content_id' => 'elastic#edit', :as=>'edit_section'
  post '/:locale/section/:key/update/:content_id' => 'elastic#update', :as=>'update_section'
  
  # filesystem construction style - live edit
  match '/:locale/liquid/edit/:content_id/*filepath' => 'elastic#edit', :as=>'edit_liquid'
  post '/:locale/liquid/update/:content_id/*filepath' => 'elastic#update', :as=>'update_liquid'
  
  
  # match '/:locale/edit/:key/:content_config_id'=>'elastic#edit', :as=>'edit'
  # match '/:locale/update/:key/:content_config_id'=>'elastic#update', :as=>'update'
  
  match '/:locale/toggle_reload'=>'elastic#toggle_reload', :as=>'toggle_reload'  
  match '/:locale/access_denied' => 'elastic#access_denied', :as=>'access_denied'
  # -- devise --

  devise_for :users, :class_name=>'Elastic::User', :module=>:devise,
    :controllers => { :sessions => "elastic/devise/sessions" } #, :skip=>'sessions' #, :controller=>'elastic/devise/sessions'
    
  
  # -- backend --
  
  scope "/:locale" do
    
    namespace 'admin' do
      resource :configuration
      # zalohovanie celeho systemu
    end
  
    namespace 'master' do
      resources :sites do
        post 'structure_import', :on=>:member
        post 'structure_export', :on=>:member
        post 'content_import', :on=>:member
        post 'content_export', :on=>:member
        post 'toggle_reload_theme', :on=>:member
        post 'copy_themes', :on=>:member
      end
      resources :sections do
        post 'toggle_star', :on=>:member
        post 'toggle_hidden', :on=>:member
        post 'toggle_locked', :on=>:member
        post 'move_higher', :on=>:member
        post 'move_lower', :on=>:member
        
        get 'new_content_config', :on=>:member
        get 'cc_toggle_published/:content_config_id', :on=>:member, :action=>'cc_toggle_published', :as=>'cc_toggle_published'
        # get 'cc_move_higher/:content_config_id', :on=>:member, :action=>'cc_move_higher'                 
        # get 'cc_move_lower/:content_config_id', :on=>:member, :action=>'cc_move_higher'                         
#        resources :content_configs
      end      
    end
    
    namespace 'editor' do      
      resources :sections do        
        resources :nodes do
          get 'drop/:node_id', :on=>:member, :action=>'drop', :as=>'drop'
          post 'toggle_published', :on=>:member
          post 'toggle_star', :on=>:member
          post 'toggle_hidden', :on=>:member
          post 'toggle_locked', :on=>:member
          post 'move_higher', :on=>:member
          post 'move_lower', :on=>:member
          get 'reify/:version_id', :on=>:member, :action=>'reify', :as=>'reify'
          post 'publish_version/:version_id', :on=>:member, :action=>'publish_version', :as=>'publish_version'
          post 'publish_recent', :on=>:member #, :action=>'commit', :as=>'commit'          
          get 'restore', :on=>:collection, :action=>'restore', :as=>'restore'
          
          resources :contents
        end      
      end
      resources :galleries do
        post 'toggle_star', :on=>:member
        post 'toggle_hidden', :on=>:member
        post 'toggle_locked', :on=>:member
        post 'regenerate', :on=>:member
        
        get 'f_destroy', :on=>:member, :action=>'f_destroy', :as=>'f_destroy'
        get 'f_star', :on=>:member, :action=>'f_star', :as=>'f_star'
        
        # get 'f_edit/:file_record_id', :on=>:member, :action=>'f_edit', :as=>'f_edit'
        # put 'f_update/:file_record_id', :on=>:member, :action=>'f_update', :as=>'f_update'
        resources :file_records do
          post 'toggle_star', :on=>:member
        end
      end
      resources :users do
      end
      resource :site do
        post 'import'
        post 'export'
      end      
    end
      
  end
  
end
  