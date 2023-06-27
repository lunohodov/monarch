require "rails/generators"
require "rails/generators/active_record"

module MonarchMigrate
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def self.next_migration_number(dir)
        ActiveRecord::Generators::Base.next_migration_number(dir)
      end

      def create_monarch_migrate_migration
        return if migration_exists?
        return if migration_table_exists?

        migration_template(
          "create_data_migration_records.rb.erb",
          "db/migrate/create_data_migration_records.rb",
          migration_version: migration_version
        )
      end

      def migration_version
        "[#{ActiveRecord::Migration.current_version}]"
      end

      def migration_table_name
        MigrationRecord.table_name
      end

      private

      def migration_table_exists?
        ActiveRecord::Base.connection.data_source_exists?(migration_table_name)
      end

      def migration_exists?
        Dir.glob("db/migrate/*.rb").any? { |f| f.end_with?("create_data_migration_records.rb") }
      end
    end
  end
end
