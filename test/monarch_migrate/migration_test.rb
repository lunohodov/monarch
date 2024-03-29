require "test_helper"

module MonarchMigrate
  class MigrationTest < ActiveSupport::TestCase
    include ActiveSupport::Testing::Stream
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
      out = capture(:stdout) { @migration.run }

      assert_migration_did_run(@migration.version)

      assert_match %r{Running data migration #{@migration.version}: #{@migration.name}}, out
      assert_match %r{Migration complete}, out
      assert_match %r{after_commit}, out
    end

    test "rollbacks on failure" do
      bad_migration = Migration.new(
        File.expand_path("../fixtures/db/data_migrate/200010101010_bad_migration.rb", __dir__)
      )

      out = capture(:stdout) do
        assert_raises(ActiveRecord::StatementInvalid) { bad_migration.run }
      end

      refute_migration_did_run(bad_migration.version)

      assert_match %r{Migration failed due to}, out
      assert_match %r{some_non_existing_function}, out
      assert_no_match %r{after_commit}, out
    end
  end
end
