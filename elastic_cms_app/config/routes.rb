Rails.application.routes.draw do
  
#  match '/auth/identity/callback', :to=> 'tvoja#matka'
  
  mount Elastic::Engine => "/"


  # match '/auth/:provider/callback', :to => 'sessions#create'
  # match '/logout', to: 'sessions#destroy'  
  

end
