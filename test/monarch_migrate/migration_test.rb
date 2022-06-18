require "test_helper"

module MonarchMigrate
  class MigrationTest < ActiveSupport::TestCase
    class GoodMigration
      def self.migrate!
      end
    end

    class BadMigration
      def self.migrate!
        raise "Error from migration"
      end
    end

    include Testing::Assertions

    setup do
      migration_path = File.expand_path("../fixtures/db/data_migrate/200010101011_good_migration.rb", __dir__)
      @migration = Migration.new(migration_path)
    end

    test "filename" do
      assert_equal @migration.filename, "200010101011_good_migration.rb"
    end

    test "name" do
      assert_equal @migration.name, "Good migration"
    end

    test "version" do
      assert_equal @migration.version, "200010101011"
    end

    test "pending when no record exists" do
      assert @migration.pending?
    end

    test "pending when record exists" do
      MigrationRecord.create(version: @migration.version)

      refute @migration.pending?
    end

    test "runs successfully" do
      out = StringIO.new

      @migration.run(out)

      assert_migration_did_run(@migration.version)

      assert_match %r{Running data migration #{@migration.version}: #{@migration.name}}, out.string
      assert_match %r{Migration complete}, out.string
    end

    test "rollbacks on failure" do
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
