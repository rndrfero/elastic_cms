# ---==---  ELASTIC CMS DEPLOYMENT SCRIPT  ---==----

# bundler bootstrap
require 'bundler/capistrano'
require 'rvm/capistrano'

set :rvm_type, :user
set :rvm_ruby_string, 'ruby-2.1.3'

set :application, "elastic-cms"

set :deploy_to, "/home/web/elastic-cms"

set :domain, "185.3.94.165" # NI server
set :user, 'web'
set :use_sudo, false

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server

set :scm, :git

set :repository, "git@github.com:rndrfero/elastic_cms.git"
set :branch, "deploy"
set :deploy_via, :remote_cache


namespace :deploy do
    task :restart do
      run "ln -s #{deploy_to}/#{shared_dir}/sockets #{current_release}/tmp/sockets"
    run "sudo systemctl restart elastic-cms-unicorn"
    end
    
    desc "link assets"
    task :link_assets do
    # The assets folder must be kept between releases
        run "ln -s #{deploy_to}/#{shared_dir}/data #{current_release}/public/data"
        run "ln -s #{deploy_to}/#{shared_dir}/home #{current_release}/home"
    end    
end

after 'deploy:update_code', 'deploy:link_assets'
