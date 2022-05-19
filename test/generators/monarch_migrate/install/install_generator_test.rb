require "test_helper"

require "fileutils"
require "generators/monarch_migrate/install/install_generator"
require "rails/generators/testing/assertions"
require "rails/generators/testing/behaviour"

module MonarchMigrate
  module Generators
    class InstallGeneratorTest < Minitest::Test
      include Rails::Generators::Testing::Behaviour
      include Rails::Generators::Testing::Assertions
      include FileUtils

      tests InstallGenerator
      destination File.expand_path("../tmp", __dir__)

      def setup
        super
        prepare_destination
      end

      def test_creates_a_migration
        ActiveRecord::Base.connection.stub(:data_source_exists?, false) do
          run_generator
        end

        assert_migration "db/migrate/create_data_migration_records.rb", /create_table :data_migration_records/
      end

      def test_does_not_create_a_migration_when_table_exists
        ActiveRecord::Base.connection.stub(:data_source_exists?, true) do
          run_generator
        end

        assert_no_migration "db/migrate/create_data_migration_records.rb"
      end
    end
  end
end
