require "test_helper"

class TasksTest < Minitest::Test
  include MonarchMigrate::Testing::Stream

  def test_migrate
    out = capture(:stdout) { Rake::Task["db:data:migrate"].execute }

    assert_match(/No data migrations pending/, out)
  end

  def test_migrate_status
    out = capture(:stdout) { Rake::Task["db:data:migrate:status"].execute }

    assert_match(/Status\s*Data Migration ID\s*Data Migration Name/, out)
  end
end
