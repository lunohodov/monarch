require "test_helper"
require "rails/generators"
require "generators/generators_test_helper"
require "generators/rails/data_migration/data_migration_generator"

module Rails
  module Generators
    class DataMigrationGeneratorTest < Rails::Generators::TestCase
      include GeneratorsTestHelper

      test "creates a migration" do
        run_generator ["test_migration"]

        assert_migration "db/data_migrate/test_migration.rb"
      end

      test "migration is removed on revoke" do
        run_generator ["test_migration"]
        run_generator ["test_migration"], behavior: :revoke

        assert_no_migration "db/data_migrate/test_migration.rb"
      end
    end
  end
end
