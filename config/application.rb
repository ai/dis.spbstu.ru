# encoding: utf-8
require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"

Bundler.require *Rails.groups(:assets) if defined?(Bundler)

module Dis
  class Application < Rails::Application
    if Rails.env.development? and !defined? Rake and !defined? Rails::Console
      config.mongoid.logger = Logger.new($stdout, :debug)
      config.mongoid.persist_in_safe_mode = true
    end
    
    config.generators do |g|
      g.test_framework      :rspec, fixture: true
      g.fixture_replacement :fabrication
    end
    
    config.i18n.default_locale = :ru

    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true
    
    config.sass.preferred_syntax = :sass
  end
end
