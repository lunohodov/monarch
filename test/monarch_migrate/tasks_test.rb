require "test_helper"

class TasksTest < Minitest::Test
  include MonarchMigrate::Testing::Stream

  def test_migrate
    out = capture(:stdout) { Rake::Task["data:migrate"].execute }

    assert_match %r{No data migrations pending}, out
  end

  def test_migrate_status
    out = capture(:stdout) { Rake::Task["data:migrate:status"].execute }

    assert_match %r{Status\s*Data Migration ID\s*Data Migration Name}, out
  end
end
