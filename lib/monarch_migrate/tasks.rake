require "monarch_migrate"

namespace :data do
  desc "Run pending data migrations, or a single version specified by environment variable VERSION"
  task migrate: :environment do
    MonarchMigrate.migrator.run
  end

  namespace :migrate do
    desc "Display status of data migrations"
    task status: :environment do
      unless ActiveRecord::Base.connection.data_source_exists?(MonarchMigrate.data_migrations_table_name)
        Kernel.abort "Data migrations table does not exist yet."
      end

      database =
        if Rails::VERSION::MAJOR < 6
          ActiveRecord::Base.connection_config[:database]
        else
          ActiveRecord::Base.connection_db_config.database
        end

      puts "\ndatabase: #{database}\n\n"
      puts "#{"Status".center(8)}  #{"Data Migration ID".ljust(19)}  Data Migration Name"
      puts "-" * 50

      MonarchMigrate.migrator.migrations_status.each do |status, version, name|
        puts "#{status.center(8)}  #{version.ljust(19)}  #{name}"
      end

      puts
    end
  end
end
