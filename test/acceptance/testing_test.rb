require "test_helper"

module MonarchMigrate
  class TestingTest < ActiveSupport::TestCase
    test "rspec tests" do
      generate_test_app("rspec_app") do
        File.write("Gemfile", <<~CONTENTS)
          source "https://rubygems.org"

          gem "rails"
          gem "sqlite3"
          gem "rspec-rails"
          gem "monarch_migrate", path: "../.."
        CONTENTS

        install_dependencies

        successfully "bundle exec rails generate rspec:install"
        successfully <<~CMD
          echo 'require "monarch_migrate/rspec"' >> spec/rails_helper.rb
        CMD

        install_monarch_migrate
        generate_data_migration

        successfully "cp #{fixture_root}/200010101011_downcase_users_name.rb db/data_migrate/"
        successfully "cp #{fixture_root}/200010101011_downcase_users_name_spec.rb spec/data_migrations/"

        successfully "bundle exec rspec"
      end
    end

    test "test_unit tests" do
      generate_test_app("test_unit_app") do
        File.write("Gemfile", <<~CONTENTS)
          source "https://rubygems.org"

          gem "rails"
          gem "sqlite3"
          gem "monarch_migrate", path: "../.."
        CONTENTS

        install_dependencies

        successfully <<~CMD
          echo 'require "monarch_migrate/test_unit"' >> test/test_helper.rb
        CMD

        install_monarch_migrate
        generate_data_migration

        successfully "cp #{fixture_root}/200010101011_downcase_users_name.rb db/data_migrate/"
        successfully "cp #{fixture_root}/200010101011_downcase_users_name_test.rb test/data_migrations/"

        successfully "bundle exec rails test"
      end
    end

    def generate_test_app(app_name)
      Dir.chdir("tmp") do
        FileUtils.rm_rf(app_name)
        successfully <<-CMD.squish
          bundle exec rails new #{app_name}
            --no-rc
            --skip-action-cable
            --skip-action-mailbox
            --skip-action-text
            --skip-active-job
            --skip-active-storage
            --skip-bootsnap
            --skip-bundle
            --skip-gemfile
            --skip-git
            --skip-javascript
            --skip-keeps
            --skip-sprockets
            --skip-asset-pipeline
        CMD
        Dir.chdir(app_name) { yield }
      end
    end

    def install_dependencies
      successfully "bundle install --local"
    end

    def install_monarch_migrate
      successfully "bundle exec rails generate model User name:string"
      successfully "bundle exec rails generate monarch_migrate:install"
      successfully "bundle exec rake db:migrate db:test:prepare"
    end

    def generate_data_migration
      successfully "bundle exec rails generate data_migration backfill_users_name"
    end

    def fixture_root
      File.expand_path("../fixtures/acceptance", __dir__)
    end

    def successfully(command)
      return_value = system(command)
      assert_equal true, return_value
    end
  end
end
