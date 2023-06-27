require "rails/generators"
require "monarch_migrate/migration"

module Rspec
  module Generators
    class DataMigrationGenerator < Rails::Generators::NamedBase
      include MonarchMigrate::Migration::Lookup

      source_root File.expand_path("templates", __dir__)

      def create_data_migration_test
        if spec_file_name
          template("data_migration_spec.rb.erb", File.join(destination_dir, spec_file_name))
        end
      end

      private

      def described_class
        File.basename(spec_file_name, ".*")
      end

      def destination_dir
        File.join(destination_root, "spec/data_migrations")
      end

      def spec_file_name
        @spec_file_name ||=
          if behavior == :invoke
            name = migration_exists?(MonarchMigrate.migrator.path, file_name)
            File.basename(name, ".*") << "_spec.rb" if name
          else
            name = migration_exists?(destination_dir, "#{file_name}_spec")
            File.basename(name) if name
          end
      end
    end
  end
end
