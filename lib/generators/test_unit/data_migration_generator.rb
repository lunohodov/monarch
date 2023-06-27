require "rails/generators"
require "monarch_migrate/migration"

module TestUnit
  module Generators
    class DataMigrationGenerator < Rails::Generators::NamedBase
      include MonarchMigrate::Migration::Lookup

      source_root File.expand_path("templates", __dir__)

      check_class_collision suffix: "Test"

      def create_data_migration_test_file
        if test_file_name
          template "unit_test.rb.erb", File.join(destination_dir, test_file_name)
        end
      end

      private

      def test_file_name
        @test_file_name ||=
          if behavior == :invoke
            name = migration_exists?(MonarchMigrate.migrator.path, file_name)
            File.basename(name, ".*") << "_test.rb" if name
          else
            name = migration_exists?(destination_dir, "#{file_name}_test")
            File.basename(name) if name
          end
      end

      def destination_dir
        File.join(destination_root, "test/data_migrations")
      end
    end
  end
end
