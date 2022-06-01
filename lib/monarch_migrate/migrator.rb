# frozen_string_literal: true

module MonarchMigrate
  class Migrator
    attr_reader :path
    attr_reader :version

    def initialize(path, version: nil)
      @path = path.to_s
      @version = version
    end

    def migrations
      migration_files.sort.map do |f|
        Migration.new(f)
      end
    end

    def pending_migrations
      migrations.select(&:pending?)
    end

    def run(io = $stdout)
      if pending_migrations.any?
        io.puts "Running #{pending_migrations.size} data migrations"
        pending_migrations.sort_by(&:version).each { |m| m.run(io) }
      else
        io.puts "No data migrations pending"
      end
    end

    def migrations_status
      db_list = MigrationRecord.normalized_versions

      file_list = migrations.filter_map do |migration|
        version = migration.version
        status = db_list.delete(version) ? "up" : "down"
        [status, version, migration.name]
      end

      db_list.map! do |version|
        ["up", version, "***** NO FILE *****"]
      end

      (db_list + file_list).sort_by { |_, version, _| version.to_i }
    end

    private

    def migration_files
      if version
        Dir["#{path}/#{version}_*.rb"]
      else
        Dir["#{path}/*_*.rb"]
      end
    end
  end
end
