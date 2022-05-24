require "test_helper"

module MonarchMigrate
  class MigratorTest < Minitest::Test
    def setup
      super
      migrations_path = File.expand_path("../fixtures/db/data_migrate", __dir__)
      @migrator = Migrator.new(migrations_path, logger: stub_everything("logger", info: nil))
    end

    def teardown
      super
      MigrationRecord.destroy_all
    end

    def test_migrations_include_all_migration_files
      actual = @migrator.migrations.map(&:filename)
      expected = ["200010101010_bad_migration.rb", "200010101011_good_migration.rb"]

      assert_equal expected, actual
    end

    def test_pending_migrations_exclude_ran_migrations
      MigrationRecord.create!(version: "200010101010")

      assert_equal ["200010101011_good_migration.rb"], @migrator.pending_migrations.map(&:filename)
    end

    def test_runs_pending_migrations
      MigrationRecord.create!(version: "200010101010")

      refute MigrationRecord.exists?(version: "200010101011")

      @migrator.run

      assert MigrationRecord.exists?(version: "200010101011")
    end
  end
end
