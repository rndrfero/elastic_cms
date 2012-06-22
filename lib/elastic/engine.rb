module Elastic
  class Engine < ::Rails::Engine
    isolate_namespace Elastic
    
    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
    
  end
end
