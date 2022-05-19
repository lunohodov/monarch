require "test_helper"

require "generators/monarch_migrate/data_migration/data_migration_generator"

module MonarchMigrate
  module Generators
    class DataMigrationGeneratorTest < TestCase
      tests DataMigrationGenerator
      destination File.expand_path("../tmp", __dir__)

      def test_creates_a_migration
        run_generator ["test_migration"]

        assert_migration "db/data_migrate/test_migration.rb"
      end
    end
  end
end
