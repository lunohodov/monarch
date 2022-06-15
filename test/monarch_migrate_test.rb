require "test_helper"

class MonarchMigrateTest < ActiveSupport::TestCase
  test "the root path to the data migration files" do
    assert_equal "db/data_migrate", MonarchMigrate.data_migrations_path
  end

  test "the table name for the data migration records" do
    assert_equal MonarchMigrate.data_migrations_table_name, "data_migration_records"
  end

  test "has a version number" do
    refute_nil MonarchMigrate::VERSION
  end

  test "migrator" do
    migrator = MonarchMigrate.migrator

    assert_equal MonarchMigrate.data_migrations_path, migrator.path
  end

  test "migrator with specified migration version" do
    fetch_stub = ->(key, _) { "abc" if key == "VERSION" }

    ENV.stub(:fetch, fetch_stub) do
      assert_equal "abc", MonarchMigrate.migrator.version
    end
  end
end
