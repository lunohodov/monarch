require "bundler/gem_tasks"
require "rake/testtask"

namespace :fake do
  require_relative "test/fake/application"
  Fake::Application.load_tasks
end

Rake::TestTask.new("test") do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
    .exclude("test/acceptance/**/*_test.rb")
    .exclude("test/fixtures/**/*_test.rb")
end

Rake::TestTask.new("test:acceptance") do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/acceptance/*_test.rb"]
end

task default: %w[test test:acceptance]
