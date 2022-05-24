require "test_helper"

class MonarchMigrateTest < Minitest::Test
  def test_migrations_path
    assert_equal MonarchMigrate.migrations_path, "db/data_migrate"
  end

  def test_migrations_table_name
    assert_equal MonarchMigrate.migrations_table_name, "data_migration_records"
  end

  def test_version_number
    refute_nil MonarchMigrate::VERSION
  end

  def test_migrator
    migrator = MonarchMigrate.migrator

    assert_equal Rails.root.join("db/data_migrate").to_s, migrator.path
    assert_equal Rails.logger, migrator.logger
  end
end
