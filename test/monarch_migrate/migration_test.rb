require "test_helper"

module MonarchMigrate
  class MigrationTest < Minitest::Test
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
      @migration = Migration.new(migration_path, logger: stub_everything("logger", info: nil))
    end

    def teardown
      super
      MigrationRecord.destroy_all
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

    def test_run_creates_a_migration_record
      @migration.run

      assert MigrationRecord.find_by(version: @migration.version)
    end

    def test_run_will_rollback_when_migration_fails
      migration_path = File.expand_path("../fixtures/db/data_migrate/200010101010_bad_migration.rb", __dir__)
      bad_migration = Migration.new(migration_path, logger: stub_everything("logger", info: nil))

      bad_migration.run

      assert_equal MigrationRecord.count, 0
    end
  end
end
