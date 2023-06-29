require "rails/generators"
require "rails/generators/active_record/migration"

module MonarchMigrate
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      class_option :database, type: :string, aliases: %i[--db], desc: "The database for your migration. By default, the current environment's primary database is used."

      source_root File.expand_path("templates", __dir__)

      def create_monarch_migrate_migration
        return if migration_exists?
        return if migration_table_exists?

        migration_template(
          "create_data_migration_records.rb.erb",
          "#{db_migrate_path}/create_data_migration_records.rb",
          migration_version: migration_version
        )
      end

      no_commands do
        def migration_version
          "[#{ActiveRecord::Migration.current_version}]"
        end

        def migration_table_name
          MigrationRecord.table_name
        end
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
