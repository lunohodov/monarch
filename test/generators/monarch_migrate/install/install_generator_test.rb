require "test_helper"
require "rails/generators"
require "generators/monarch_migrate/install/install_generator"

module MonarchMigrate
  module Generators
    class InstallGeneratorTest < Rails::Generators::TestCase
      tests InstallGenerator
      destination File.expand_path("../tmp", __dir__)

      setup :prepare_destination

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
    end
  end
end
