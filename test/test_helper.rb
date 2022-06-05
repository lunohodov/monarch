$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

ENV["RAILS_ENV"] ||= "test"

require "fake/application"
require "fileutils"
require "minitest/autorun"
require "rails"
require "rails/generators/testing/assertions"
require "rails/generators/testing/behaviour"
require "rails/test_help"

require "monarch_migrate"

module MonarchMigrate
  module Testing
    module DataMigrations
      def refute_migration_did_run(version)
        refute MigrationRecord.exists?(version: version)
      end

      def assert_migration_did_run(version)
        assert MigrationRecord.exists?(version: version)
      end

      def assert_output_match(matcher)
        assert_match(matcher, @out.string)
      end
    end

    module Stream
      def capture(stream)
        stream = stream.to_s
        captured_stream = Tempfile.new(stream)
        stream_io = instance_eval("$#{stream}", __FILE__, __LINE__)
        origin_stream = stream_io.dup
        stream_io.reopen(captured_stream)

        yield

        stream_io.rewind
        captured_stream.read
      ensure
        captured_stream.close
        captured_stream.unlink
        stream_io.reopen(origin_stream)
      end
    end
  end

  class TestCase < Minitest::Test
    include Testing::DataMigrations

    def setup
      super
      MigrationRecord.delete_all
    end
  end

  module Generators
    class TestCase < Minitest::Test
      include Rails::Generators::Testing::Behaviour
      include Rails::Generators::Testing::Assertions
      include FileUtils

      def setup
        super
        prepare_destination
      end

      def teardown
        super
        FileUtils.rm_rf(destination_root)
      end
    end
  end
end

Rails.application.load_tasks

Fake::Application.initialize!
