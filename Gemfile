source 'http://rubygems.org'

gem 'rails', '3.1.0'

gem 'mongoid'
gem 'bson_ext'

gem 'json'
gem 'haml'
gem 'nokogiri'

gem 'oa-openid'
gem 'email_validator'

gem 'kramdown'
gem 'r18n-core'

gem 'visibilityjs'

group :assets do
  gem 'compass', '>= 0.12.alpha.0'
  gem 'sass-rails'
  gem 'coffee-rails'
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
