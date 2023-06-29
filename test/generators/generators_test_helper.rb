require "rails/generators"
require "rails/generators/test_case"

Rails.application.load_generators

module GeneratorsTestHelper
  def self.included(base)
    base.class_eval do
      destination File.expand_path("../fixtures/tmp", __dir__)
      setup :prepare_destination

      setup { Rails.application.config.root = Pathname("../fixtures").expand_path(__dir__) }

      begin
        base.tests Rails::Generators.const_get(base.name.delete_suffix("Test"))
      rescue
      end
    end
  end

  def with_schema_migrations_path(migrations_path)
    original_configurations = ActiveRecord::Base.configurations
    ActiveRecord::Base.configurations = {
      test: {
        database: "db/primary.sqlite3",
        migrations_paths: migrations_path
      }
    }
    yield
  ensure
    ActiveRecord::Base.configurations = original_configurations
  end
end
