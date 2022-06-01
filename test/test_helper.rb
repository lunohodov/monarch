$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

ENV["RAILS_ENV"] ||= "test"

require "fake/application"
require "fileutils"
require "minitest/autorun"
require "mocha/minitest"
require "rails"
require "rails/generators/testing/assertions"
require "rails/generators/testing/behaviour"
require "rails/test_help"

require "monarch_migrate"

module MonarchMigrate
  module Testing
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

  module Generators
    module Testing
      def self.included(other)
        other.include Rails::Generators::Testing::Behaviour
        other.include Rails::Generators::Testing::Assertions
        other.include FileUtils
      end

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
