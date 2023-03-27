require_relative "lib/monarch_migrate/version"

Gem::Specification.new do |spec|
  spec.name = "monarch_migrate"
  spec.version = MonarchMigrate::VERSION
  spec.authors = ["Yanko Ivanov"]
  spec.email = ["yanko.ivanov@gmail.com"]

  spec.summary = "A library for Rails developers who are not willing to leave data migrations to chance."
  spec.homepage = "https://github.com/lunohodov/monarch"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/lunohodov/monarch"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|gemfiles|tmp)/}) }
  end

  spec.add_dependency("rails", ">= 6.0")
end
