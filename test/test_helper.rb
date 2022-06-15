$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

ENV["RAILS_ENV"] ||= "test"

require "fake/application"
require "fileutils"
require "minitest/autorun"
require "rails"
require "rails/test_help"

require "monarch_migrate"

module MonarchMigrate
  module Testing
    module Assertions
      def refute_migration_did_run(version)
        refute MigrationRecord.exists?(version: version)
      end

      def assert_migration_did_run(version)
        assert MigrationRecord.exists?(version: version)
      end
    end
  end
end

class ActiveSupport::TestCase
  def create_migrator(path = nil, version: nil)
    path ||= File.expand_path("fixtures/db/data_migrate", __dir__)
    MonarchMigrate::Migrator.new(path, version: version)
  end
end

Rails.application.load_tasks

Fake::Application.initialize!
