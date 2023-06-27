require "test_helper"
require "rails/generators"
require "generators/generators_test_helper"
require "generators/rspec/data_migration_generator"

module Rspec
  module Generators
    class DataMigrationGeneratorTest < Rails::Generators::TestCase
      include GeneratorsTestHelper

      test "creates a spec" do
        stubbed_migrator = create_migrator

        MonarchMigrate.stub(:migrator, stubbed_migrator) do
          run_generator ["good_migration"]

          assert_migration "spec/data_migrations/good_migration_spec.rb"
        end
      end

      test "removes the spec on revoke" do
        stubbed_migrator = create_migrator

        MonarchMigrate.stub(:migrator, stubbed_migrator) do
          run_generator ["good_migration"]
          run_generator ["good_migration"], behavior: :revoke

          assert_no_migration "spec/data_migrations/good_migration_spec.rb"
        end
      end

      test "skips creating a spec when data migration does not exist" do
        output = run_generator ["good_migration"]

        assert_empty output
        assert_no_migration "spec/data_migrations/good_migration_spec.rb"
      end
    end
  end
end
