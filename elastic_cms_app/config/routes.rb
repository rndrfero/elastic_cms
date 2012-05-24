Rails.application.routes.draw do

  devise_scope :user do
    match '/login' => 'elastic/devise/sessions#new'
    match '/logout' => 'elastic/devise/sessions#destroy'
    # match '/login' => 'devise/sessions#new'
    # match '/logout' => 'devise/sessions#destroy'
  end  
  
  mount Elastic::Engine => "/"
  
end
