source "http://rubygems.org"

# Declare your gem's dependencies in elastic.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# jquery-rails is used by the dummy application
gem "jquery-rails"
gem 'mysql2', '0.3.10'
#gem 'activerecord-mysql2-adapter'

group :assets do
  gem 'uglifier'
  gem 'sass-rails' #,   '~> 3.2.3'
end

gem 'therubyracer' # javascript runtime

gem 'acts_as_list'
gem 'ancestry'

gem 'rmagick', '2.13.4' # head
#gem 'rmagick', '2.13.3' # <--- toto je u mna na locale  = c6c68a98d4ece487fd74a3cdd750144caef47e97


gem 'liquid'
gem 'nokogiri'

gem 'kaminari'

gem 'wake', :git => 'git://github.com/rndrfero/wake.git'
#gem 'wake', :path => '~/rails_gems/wake'

gem 'bcrypt-ruby'
gem 'devise'

gem 'bluecloth'

gem 'thinking-sphinx', '2.0.10'
gem 'paper_trail', '~> 2'

gem 'exception_notification'

gem 'rubyzip'
gem 'iconv'

group :development do
  gem 'capistrano', '~> 2.15.5'
  gem 'rvm-capistrano'
end

gem 'unicorn'

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
