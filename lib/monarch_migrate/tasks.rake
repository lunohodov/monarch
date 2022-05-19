require "monarch_migrate"

namespace :db do
  namespace :data do
    desc "Run pending data migrations, or a single version specified by environment variable VERSION"
    task migrate: :environment do
      MonarchMigrate.migrator.run
    end
  end
end
