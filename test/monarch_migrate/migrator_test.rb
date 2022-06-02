require "test_helper"

module MonarchMigrate
  class MigratorTest < Minitest::Test
    include Testing::Stream

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

      capture(:stdout) { @migrator.run }

      assert_migration_did_run("200010101011")
    end

    def test_runs_only_the_specified_migration
      migrator = create_migrator(version: "200010101011")

      capture(:stdout) { migrator.run }

      refute_migration_did_run("200010101010")
      assert_migration_did_run("200010101011")
    end

    def test_run_raises_an_error_when_the_specified_migration_does_not_exist
      migrator = create_migrator(version: "0")

      assert_raises(ActiveRecord::UnknownMigrationVersionError) { capture(:stdout) { migrator.run } }
    end

    def test_migrations_status_is_empty_without_any_migrations
      status = Dir.mktmpdir do |dir|
        create_migrator(dir).migrations_status
      end

      assert_empty status
    end

    def test_migrations_status
      MigrationRecord.create!(version: "200010101000")

      status = @migrator.migrations_status

      assert_equal 3, status.size
      assert_equal status[0], ["up", "200010101000", "***** NO FILE *****"]
      assert_equal status[1], ["down", "200010101010", "Bad migration"]
      assert_equal status[2], ["down", "200010101011", "Good migration"]
    end

    def refute_migration_did_run(version)
      refute MigrationRecord.exists?(version: version)
    end

    def assert_migration_did_run(version)
      assert MigrationRecord.exists?(version: version)
    end

    def create_migrator(path = nil, version: nil)
      path ||= File.expand_path("../fixtures/db/data_migrate", __dir__)

      Migrator.new(path, version: version)
    end
  end
end
