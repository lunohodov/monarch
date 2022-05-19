# frozen_string_literal: true

module MonarchMigrate
  class MigrationRecord < ActiveRecord::Base
    self.table_name = MonarchMigrate.data_migrations_table_name
  end
end
