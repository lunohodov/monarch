require "bundler/gem_tasks"
require "rake/testtask"

namespace :fake do
  require_relative "test/fake/application"
  Fake::Application.load_tasks
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task default: :test
