require "test_helper"

class DowncaseUsersNameTest < MonarchMigrate::TestCase
  def test_assigns_downcased_name
    user = User.create!(name: "Guybrush THREEPWOOD")

    run_data_migration

    assert_equal "guybrush threepwood", user.reload.name
  end
end
