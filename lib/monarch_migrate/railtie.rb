module MonarchMigrate
  class Railtie < Rails::Railtie
    railtie_name :monarch_migrate

    rake_tasks do
      load File.expand_path("tasks.rake", __dir__)
    end
  end
end
