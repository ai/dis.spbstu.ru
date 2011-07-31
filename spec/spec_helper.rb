# encoding: utf-8
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec

  config.after do
    Mongoid.master.collections.select { |i| i.name !~ /system/ }.each(&:drop)
  end
end

RSpec::Matchers.define :be_bad_request do
  match do |response|
    response.status == 400
  end
  failure_message_for_should do |response|
    "excepted 400 response status, got #{response.status}"
  end
  failure_message_for_should_not do |response|
    "excepted response not to have 400 status, got #{response.status}"
  end
end
