require "active_support/core_ext/string"
require "active_support/testing/stream"

module MonarchMigrate
  module Testing
    MigrationRunError = Class.new(RuntimeError)

    module Helpers
      include ::ActiveSupport::Testing::Stream

      def data_migration
        @data_migration ||=
          begin
            filename = data_migration_basename
            migrator
              .migrations
              .find(method(:not_found)) { |m| m.filename.ends_with?(filename) }
          end
      end

      def run_data_migration
        output = capture(:stdout) { data_migration.run }
        ensure_no_error(output)
      end

      protected

      def data_migration_basename
        raise NotImplementedError
      end

      def data_migration_failed(message)
        raise NotImplementedError
      end

      def migrator
        ::MonarchMigrate.migrator
      end

      def not_found
        path = File.join(migrator.path, "*_#{data_migration_basename}")
        raise <<~MSG
          \n\r
          Can not find data migration at path: #{path}
          \n\r
        MSG
      end

      def ensure_no_error(str)
        if %r{Migration failed}.match?(str)
          data_migration_failed(<<-CMD)
            Failed running data migration: #{data_migration.filename}
            \n\r
            Output:
            \n\r
            \n\r
            #{str}
          CMD
        end
      end
    end

    module RSpec
      include Helpers

      def data_migration_basename
        spec_path = ::RSpec.current_example.metadata[:file_path]
        File.basename(spec_path).sub(/_spec\.rb$/, ".rb")
      end

      def data_migration_failed(message)
        fail message
      end
    end

    module TestUnit
      include Helpers

      def data_migration_basename
        File.basename(self.class.name.underscore).sub(/_test$/, ".rb")
      end

      def data_migration_failed(message)
        flunk message
      end
    end
  end
end
