require "test_helper"
require "generators/rspec/data_migration_generator"

module Rspec
  module Generators
    class DataMigrationGeneratorTest < ::Rails::Generators::TestCase
      tests DataMigrationGenerator
      destination File.expand_path("../tmp", __dir__)

      setup :prepare_destination
      teardown :prepare_destination

      test "creates a migration spec" do
        stubbed_migrator = create_migrator

        MonarchMigrate.stub(:migrator, stubbed_migrator) do
          run_generator ["good_migration"]

          # Take advantage of version numbering when inferring the filename
          assert_migration "spec/data_migrations/good_migration_spec.rb"
        end
      end

      test "aborts with message when data migration does not exist" do
        output = run_generator ["good_migration"]

        assert_match %r{Expecting a data migration matching \*good_migration.rb but none found. Aborting}, output
        # Take advantage of version numbering when inferring the filename
        assert_no_migration "spec/data_migrations/good_migration_spec.rb"
      end
    end
  end
end
