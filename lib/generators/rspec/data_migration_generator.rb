module Rspec
  module Generators
    class DataMigrationGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      def create_data_migration_test
        unless data_migration
          say "Expecting a data migration matching *#{data_migration_pattern} but none found. Aborting..."
          return
        end

        template(
          "data_migration_spec.rb.erb",
          File.join("spec/data_migrations", "#{described_class}_spec.rb")
        )
      end

      private

      def described_class
        File.basename(data_migration.filename, ".rb")
      end

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
