require "test_helper"

module MonarchMigrate
  class MigrationRecordTest < TestCase
    def test_table_name
      assert_equal "data_migration_records", MigrationRecord.table_name

      ActiveRecord::Base.table_name_prefix = "prefix_"
      ActiveRecord::Base.table_name_suffix = "_suffix"
      assert_equal "prefix_data_migration_records_suffix", MigrationRecord.table_name
    ensure
      MigrationRecord.reset_table_name
      ActiveRecord::Base.table_name_prefix = ""
      ActiveRecord::Base.table_name_suffix = ""
    end
  end
end
