$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

ENV["RAILS_ENV"] ||= "test"

require "fake/application"
require "fileutils"
require "minitest/autorun"
require "mocha/minitest"
require "rails"
require "rails/generators/testing/assertions"
require "rails/generators/testing/behaviour"
require "rails/test_help"

require "monarch_migrate"

module MonarchMigrate
  module Generators
    module Testing
      def self.included(other)
        other.include Rails::Generators::Testing::Behaviour
        other.include Rails::Generators::Testing::Assertions
        other.include FileUtils
      end

      def setup
        super
        prepare_destination
      end

      def teardown
        super
        FileUtils.rm_rf(destination_root)
      end
    end
  end
end

Rails.application.load_tasks

Fake::Application.initialize!
