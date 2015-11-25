$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "elastic/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "elastic"
  s.version     = Elastic::VERSION
  s.authors     = ["Frantisek Psotka"]
  s.email       = ["frantisek.psotka@stylez.sk"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Elastic."
  s.description = "TODO: Description of Elastic."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  #s.add_dependency "rails", "~> 3.2.3.rc2"
    
 # s.add_dependency "rails", :git => "git://github.com/rails/rails.git"
  
  # s.add_dependency "jquery-rails"

  #s.add_development_dependency "sqlite3"
  
  s.add_dependency 'liquid'
  s.add_dependency 'nokogiri'
  s.add_dependency 'devise',  '2.2.3' #'3.2.2'
  s.add_dependency 'iconv'
  s.add_dependency 'acts_as_list'
  s.add_dependency 'ancestry'
  s.add_dependency 'paper_trail', '~> 2'
  s.add_dependency 'rubyzip'
end
