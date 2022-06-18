module TestUnit
  module Generators
    class DataMigrationGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      check_class_collision suffix: "Test"

      def create_data_migration_test
        unless data_migration
          say "Expecting a data migration matching *#{data_migration_pattern} but none found. Aborting..."
          return
        end

        prefix = File.basename(data_migration.filename, ".rb")

        template "unit_test.rb.erb", File.join("test/data_migrations", "#{prefix}_test.rb")
      end

      private

      def data_migration_pattern
        "#{file_name}.rb"
      end

      def data_migration
        @data_migration ||=
          MonarchMigrate.migrator
            .migrations
            .reverse
            .find { |m| m.filename.ends_with?(data_migration_pattern) }
      end
    end
  end
end
