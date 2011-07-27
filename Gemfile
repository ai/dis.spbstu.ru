source 'http://rubygems.org'

gem 'rails', '3.1.0.rc5'

gem 'mongoid'
gem 'bson_ext'

gem 'json'
gem 'haml'
gem 'compass', git: 'https://github.com/chriseppstein/compass.git',
               branch: 'rails31'
gem 'sass-rails', '~> 3.1.0.rc'
gem 'coffee-script'
gem 'uglifier'
gem 'therubyracer'

gem 'oa-openid'
gem 'email_validator'

gem 'kramdown'
gem 'r18n-core'

group :development do
  gem 'oily_png'
  gem 'wirble'
  gem 'thin'
end

group :test, :development do
  gem 'rspec-rails'
  gem 'fabrication'
end

YAML::ENGINE.yamler = 'psych' # Исправляем ошибку Bundler
