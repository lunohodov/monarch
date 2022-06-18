require "monarch_migrate/testing"

RSpec.configure do |config|
  config.include MonarchMigrate::Testing::RSpec, type: :data_migration
end
