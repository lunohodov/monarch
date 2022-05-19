require "test_helper"

module MonarchMigrate
  class MigratorTest < Minitest::Test
    def setup
      super
      @migrator = create_migrator
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

      refute_migration_did_run("200010101011")

      @migrator.run

      assert_migration_did_run("200010101011")
    end

    def test_runs_only_the_specified_migration
      migrator = create_migrator(version: "200010101011")

      migrator.run

      refute_migration_did_run("200010101010")
      assert_migration_did_run("200010101011")
    end

    def refute_migration_did_run(version)
      refute MigrationRecord.exists?(version: version)
    end

    def assert_migration_did_run(version)
      assert MigrationRecord.exists?(version: version)
    end

    def create_migrator(version: nil)
      Migrator.new(
        File.expand_path("../fixtures/db/data_migrate", __dir__),
        version: version,
        logger: stub_everything("logger", info: nil)
      )
    end
  end
end
