module Elastic
  class Engine < ::Rails::Engine
    isolate_namespace Elastic
    
    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end

    # initializer "elastic_cms.assets.precompile" do |app|
    #   app.config.assets.precompile += %w(application.css application.js)
    # end    
  end
end
