require "test_helper"
require "rails/generators"
require "generators/monarch_migrate/data_migration/data_migration_generator"

module MonarchMigrate
  module Generators
    class DataMigrationGeneratorTest < Rails::Generators::TestCase

      tests DataMigrationGenerator
      destination File.expand_path("../tmp", __dir__)

      test "creates a migration" do
        run_generator ["test_migration"]

        assert_migration "db/data_migrate/test_migration.rb"
      end
    end
  end
end
