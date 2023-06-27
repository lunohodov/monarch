require "test_helper"
require "rails/generators"
require "generators/generators_test_helper"
require "generators/test_unit/data_migration_generator"

module TestUnit
  module Generators
    class DataMigrationGeneratorTest < Rails::Generators::TestCase
      include GeneratorsTestHelper

      test "creates a test" do
        stubbed_migrator = create_migrator

        MonarchMigrate.stub(:migrator, stubbed_migrator) do
          run_generator ["good_migration"]

          assert_migration "test/data_migrations/good_migration_test.rb"
        end
      end

      test "removes the test on revoke" do
        stubbed_migrator = create_migrator

        MonarchMigrate.stub(:migrator, stubbed_migrator) do
          run_generator ["good_migration"]
          run_generator ["good_migration"], behavior: :revoke

          assert_no_migration "test/data_migrations/good_migration_test.rb"
        end
      end

      test "skips creating a test when data migration does not exist" do
        output = run_generator ["good_migration"]

        assert_empty output
        assert_no_migration "test/data_migrations/good_migration_test.rb"
      end
    end
  end
end
