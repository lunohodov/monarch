# frozen_string_literal: true

module MonarchMigrate
  class MigrationRecord < ActiveRecord::Base
    class << self
      def table_name
        "#{table_name_prefix}#{MonarchMigrate.data_migrations_table_name}#{table_name_suffix}"
      end

      def normalized_versions
        all_versions.map { |v| normalize_version(v) }
      end

      private

      def all_versions
        order(version: :asc).pluck(:version)
      end

      def normalize_version(version)
        "%.3d" % version.to_i
      end
    end
  end
end
