source 'http://rubygems.org'

gem 'rails', '3.1.0.rc5'

gem 'mongoid'
gem 'bson_ext'

gem 'json'
gem 'haml'

gem 'oa-openid'
gem 'email_validator'

gem 'kramdown'
gem 'r18n-core'

gem 'visibilityjs'

group :assets do
  gem 'compass', git: 'https://github.com/chriseppstein/compass.git'
  gem 'sass-rails',   '~> 3.1.0.rc'
  gem 'coffee-rails', '~> 3.1.0.rc'
  gem 'uglifier'
  gem 'therubyracer'
end

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
