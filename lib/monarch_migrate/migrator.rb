# frozen_string_literal: true

require "logger"

module MonarchMigrate
  class Migrator
    attr_reader :path, :logger

    def initialize(path, logger: nil)
      @path = path.to_s
      @logger = logger || Logger.new($stderr)
    end

    def migrations
      migration_files.sort.map do |f|
        Migration.new(f, logger: logger)
      end
    end

    def pending_migrations
      migrations.select(&:pending?)
    end

    def run
      if pending_migrations.any?
        logger.info "Running #{pending_migrations.size} data migrations"
        pending_migrations.sort_by(&:version).each(&:run)
      else
        logger.info "No data migrations pending"
      end
    end

    private

    def migration_files
      if version
        Dir["#{path}/#{version}_*.rb"]
      else
        Dir["#{path}/*_*.rb"]
      end
    end

    def version
      ENV["VERSION"]
    end
  end
end
