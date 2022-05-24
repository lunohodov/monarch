require "rails/generators"
require "rails/generators/active_record"

module MonarchMigrate
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("../templates", __FILE__)

      def self.next_migration_number(dir)
        ActiveRecord::Generators::Base.next_migration_number(dir)
      end

      def copy_migration
        unless migration_table_exists?
          migration_template(
            "db/migrate/create_data_migration_records.rb.erb",
            "db/migrate/create_data_migration_records.rb",
            migration_version: migration_version
          )
        end
      end

      def migration_version
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
      end

      private

      def migration_table_exists?
        ActiveRecord::Base.connection.data_source_exists?(MonarchMigrate.migrations_table_name)
      end
    end
  end
end
