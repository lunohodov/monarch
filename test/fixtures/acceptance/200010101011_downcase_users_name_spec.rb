require "rails_helper"

describe "200010101011_downcase_users_name", type: :data_migration do
  subject { run_data_migration }

  it "assigns downcased name" do
    user = User.create!(name: "Guybrush THREEPWOOD")

    expect { subject }.to change { user.reload.name }.to("guybrush threepwood")
  end
end
