require "test_helper"
require "rails/generators"
require "generators/generators_test_helper"
require "generators/monarch_migrate/install/install_generator"

module MonarchMigrate
  module Generators
    class InstallGeneratorTest < Rails::Generators::TestCase
      include GeneratorsTestHelper

      test "creates a migration" do
        ActiveRecord::Base.connection.stub(:data_source_exists?, false) do
          run_generator
        end

        assert_migration "db/migrate/create_data_migration_records.rb", /create_table :data_migration_records/
      end

      test "does not create a migration when table exists" do
        ActiveRecord::Base.connection.stub(:data_source_exists?, true) do
          run_generator
        end

        assert_no_migration "db/migrate/create_data_migration_records.rb"
      end

      test "puts migration in configured path" do
        with_schema_migrations_path("db/custom_migrate") do
          ActiveRecord::Base.connection.stub(:data_source_exists?, false) do
            run_generator %w[--database=primary]
          end

          assert_migration "db/custom_migrate/create_data_migration_records.rb"
        end
      end
    end
  end
end
