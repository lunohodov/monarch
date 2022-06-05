require "test_helper"

module MonarchMigrate
  class MigrationTest < TestCase
    class GoodMigration
      def self.migrate!
      end
    end

    class BadMigration
      def self.migrate!
        raise "Error from migration"
      end
    end

    def setup
      super
      migration_path = File.expand_path("../fixtures/db/data_migrate/200010101011_good_migration.rb", __dir__)
      @migration = Migration.new(migration_path)
    end

    def test_filename
      assert_equal @migration.filename, "200010101011_good_migration.rb"
    end

    def test_name
      assert_equal @migration.name, "Good migration"
    end

    def test_version
      assert_equal @migration.version, "200010101011"
    end

    def test_is_pending_when_no_record_exists
      assert @migration.pending?
    end

    def test_is_not_pending_when_record_exists
      MigrationRecord.create(version: @migration.version)

      refute @migration.pending?
    end

    def test_run
      out = StringIO.new

      @migration.run(out)

      assert_migration_did_run(@migration.version)

      assert_match %r{Running data migration #{@migration.version}: #{@migration.name}}, out.string
      assert_match %r{Migration complete}, out.string
    end

    def test_run_will_rollback_when_migration_fails
      out = StringIO.new
      bad_migration = Migration.new(
        File.expand_path("../fixtures/db/data_migrate/200010101010_bad_migration.rb", __dir__)
      )

      bad_migration.run(out)

      refute_migration_did_run(bad_migration.version)

      assert_match %r{Migration failed due to}, out.string
      assert_match %r{Error from migration}, out.string
    end
  end
end
