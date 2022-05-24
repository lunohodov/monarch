# frozen_string_literal: true

module MonarchMigrate
  class MigrationRecord < ActiveRecord::Base
    self.table_name = MonarchMigrate.migrations_table_name
  end
end
