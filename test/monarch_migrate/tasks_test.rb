require "test_helper"

class TasksTest < Minitest::Test
  include MonarchMigrate::Testing::Stream

  def test_migrate
    out = capture(:stdout) { Rake::Task["db:data:migrate"].execute }

    assert_match(/No data migrations pending/, out)
  end
end
