# frozen_string_literal: true

# :nodoc
module MonarchMigrate
  def self.migrations_table_name
    "data_migration_records"
  end

  def self.migrations_path
    "db/data_migrate"
  end

  def self.migrator
    Migrator.new(Rails.root.join(migrations_path), logger: Rails.logger)
  end
end

require "monarch_migrate/migration"
require "monarch_migrate/migration_record"
require "monarch_migrate/migrator"
require "monarch_migrate/version"
