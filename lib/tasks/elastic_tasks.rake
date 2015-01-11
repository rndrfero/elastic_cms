# desc "Explaining what the task does"
# task :elastic do
#   # Task goes here
# end



namespace :elastic do
  
  desc "Create site for domain 'localhost' and superuser 'admin:password@example.com'"
  task :prepare => :environment do
      Rails.logger.info 'creating Elastic::User: admin@example.com password: password'
      u = Elastic::User.create! :email=>'admin@example.com', :password=>'password', :password_confirmation=>'password', 
        :name=>'The Elastic Admin', :site_id=>1
        
      Rails.logger.info "creating Elastic::Site: for host 'localhost'"
      s = Elastic::Site.create! :host=>'localhost', :title=>'Localhost Site', :is_reload_theme=>true, :master_id=>1
  end
end