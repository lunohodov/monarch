require "test_helper"

class TasksTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Stream

  test "data:migrate" do
    out = capture(:stdout) { Rake::Task["data:migrate"].execute }

    assert_match %r{No data migrations pending}, out
  end

  test "data:migrate:status" do
    out = capture(:stdout) { Rake::Task["data:migrate:status"].execute }

    assert_match %r{Status\s*Data Migration ID\s*Data Migration Name}, out
  end
end
