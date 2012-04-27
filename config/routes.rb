Elastic::Engine.routes.draw do
  
  scope "/:locale" do  
  
    namespace 'admin' do
      resources :sites
    end
  end
  
end
