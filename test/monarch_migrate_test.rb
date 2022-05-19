require "test_helper"

class MonarchMigrateTest < Minitest::Test
  def test_data_migrations_path
    assert_equal "db/data_migrate", MonarchMigrate.data_migrations_path
  end

  def test_data_migrations_table_name
    assert_equal MonarchMigrate.data_migrations_table_name, "data_migration_records"
  end

  def test_version_number
    refute_nil MonarchMigrate::VERSION
  end

  def test_migrator
    migrator = MonarchMigrate.migrator

    assert_equal MonarchMigrate.data_migrations_path, migrator.path
  end

  def test_migrator_with_specified_migration_version
    fetch_stub = ->(key, _) { "abc" if key == "VERSION" }

    ENV.stub(:fetch, fetch_stub) do
      assert_equal "abc", MonarchMigrate.migrator.version
    end
  end
end
