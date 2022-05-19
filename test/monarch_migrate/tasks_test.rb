require "test_helper"

class TasksTest < Minitest::Test
  def test_migrate
    out = StringIO.new

    Rails.stub :logger, Logger.new(out) do
      Rake::Task["db:data:migrate"].execute

      assert_match(/No data migrations pending/, out.string)
    end
  end
end
