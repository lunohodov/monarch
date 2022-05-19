require "test_helper"

require "fileutils"
require "generators/monarch_migrate/data_migration/data_migration_generator"
require "rails/generators/testing/assertions"
require "rails/generators/testing/behaviour"

module MonarchMigrate
  module Generators
    class DataMigrationGeneratorTest < Minitest::Test
      include Rails::Generators::Testing::Behaviour
      include Rails::Generators::Testing::Assertions
      include FileUtils

      tests DataMigrationGenerator
      destination File.expand_path("../tmp", __dir__)

      def setup
        super
        prepare_destination
      end

      def teardown
        super
        FileUtils.rm_rf(destination_root)
      end

      def test_creates_a_migration
        run_generator ["test_migration"]

        assert_migration "db/data_migrate/test_migration.rb"
      end
    end
  end
end
