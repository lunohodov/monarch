$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

ENV["RAILS_ENV"] ||= "test"

require "rails"
require "rails/test_help"
require "minitest/autorun"
require "mocha/minitest"
require "fake/application"

require "monarch_migrate"
# require "lib/monarch_migrate/railtie" if defined?(Rails)

Fake::Application.initialize!
