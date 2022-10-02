require "test_helper"

module MonarchMigrate
  class MigratorTest < ActiveSupport::TestCase
    include ActiveSupport::Testing::Stream
    include Testing::Assertions

    setup do
      @migrator = create_migrator
    end

    test "migrations include all migration files" do
      actual = @migrator.migrations.map(&:filename)
      expected = ["200010101010_bad_migration.rb", "200010101011_good_migration.rb"]

      assert_equal expected, actual
    end

    test "pending migrations exclude ran migrations" do
      MigrationRecord.create!(version: "200010101010")

      assert_equal ["200010101011_good_migration.rb"], @migrator.pending_migrations.map(&:filename)
    end

    test "runs pending migrations" do
      MigrationRecord.create!(version: "200010101010")

      result = nil
      out = capture(:stdout) { result = @migrator.run }

      assert_equal %w[200010101011], result.map(&:version)
      assert_match %r{Running 1 data migrations}, out

      assert_migration_did_run("200010101011")
    end

    test "runs only the specified migration" do
      migrator = create_migrator(version: "200010101011")

      result = nil
      out = capture(:stdout) { result = migrator.run }

      assert_equal %w[200010101011], result.map(&:version)
      assert_match %r{Running 1 data migrations}, out

      refute_migration_did_run("200010101010")
      assert_migration_did_run("200010101011")
    end

    test "run raises an error when the specified migration does not exist" do
      migrator = create_migrator(version: "0")

      assert_raises(ActiveRecord::UnknownMigrationVersionError) { migrator.run }
    end

    test "does not run migration twice" do
      MigrationRecord.create!(version: "200010101010")
      migrator = create_migrator(version: "200010101010")

      out = capture(:stdout) { migrator.run }

      assert_match %r{No data migrations pending}, out
    end

    test "migrations status is empty when there are no migrations" do
      status = Dir.mktmpdir do |dir|
        create_migrator(dir).migrations_status
      end

      assert_empty status
    end

    test "migrations status" do
      MigrationRecord.create!(version: "200010101000")

      status = @migrator.migrations_status

      assert_equal 3, status.size
      assert_equal status[0], ["up", "200010101000", "***** NO FILE *****"]
      assert_equal status[1], ["down", "200010101010", "Bad migration"]
      assert_equal status[2], ["down", "200010101011", "Good migration"]
    end
  end
end
