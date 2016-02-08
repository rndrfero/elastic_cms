# ---==---  ELASTIC CMS DEPLOYMENT SCRIPT  ---==----

# bundler bootstrap
require 'bundler/capistrano'
require 'rvm/capistrano'

set :rvm_type, :user
set :rvm_ruby_string, 'ruby-2.1.3'

set :application, "elastic-cms"

set :deploy_to, "/home/web/sites/elastic-cms"

set :domain, "109.74.199.18" # NI server
set :user, 'web'
set :use_sudo, false

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server

set :scm, :git

set :repository, "https://github.com/rndrfero/elastic_cms.git"
set :branch, "deploy"
set :deploy_via, :remote_cache


namespace :deploy do
    # run("cd #{deploy_to}/current && /usr/bin/env rake `<task_name>` RAILS_ENV=production")
    desc "rekompile app assets"
    task :recompile_assets do
      run "cd #{current_release}/elastic_cms_app && /usr/bin/env bundle exec rake assets:precompile RAILS_ENV=production"
    end

    task :restart do
      run "ln -s #{deploy_to}/#{shared_dir}/pids #{current_release}/elastic_cms_app/tmp/pids"
      run "ln -s #{deploy_to}/#{shared_dir}/sockets #{current_release}/elastic_cms_app/tmp/sockets"
      # run "sudo systemctl restart elastic-cms-unicorn"
    end
    
    desc "link stuff"
    task :link_stuff do
        run "ln -s #{deploy_to}/#{shared_dir}/database.yml #{current_release}/elastic_cms_app/config/database.yml"
        run "ln -s #{deploy_to}/#{shared_dir}/home #{current_release}/elastic_cms_app/home"
    end    
end

after 'deploy:update_code', 'deploy:link_stuff'
after 'deploy:update_code', 'deploy:recompile_assets'

