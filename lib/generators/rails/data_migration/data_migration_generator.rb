require "rails/generators"
require "rails/generators/migration"
require "rails/generators/active_record"

module Rails
  module Generators
    class DataMigrationGenerator < Rails::Generators::NamedBase
      include ActiveRecord::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def self.next_migration_number(_)
        ActiveRecord::Generators::Base.next_migration_number(
          MonarchMigrate.data_migrations_path
        )
      end

      def create_data_migration
        validate_file_name!

        migration_template(
          "data_migration.rb.erb",
          File.join(MonarchMigrate.migrator.path, "#{file_name}.rb")
        )
      end

      hook_for :test_framework, as: :data_migration

      private

      def validate_file_name!
        unless /^[_a-z0-9]+$/.match?(file_name)
          raise ActiveRecord::IllegalMigrationNameError.new(file_name)
        end
      end
    end
  end
end
