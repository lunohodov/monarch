# frozen_string_literal: true

require "logger"

module MonarchMigrate
  class Migration
    def initialize(path, logger: nil)
      @path = path.to_s
      @logger = logger || Logger.new($stderr)
    end

    def filename
      File.basename(path)
    end

    def name
      File.basename(path, ".rb").match(/^[0-9]+_(.*)$/)[1].humanize
    end

    def version
      filename.match(/^([0-9]+)_/)[1]
    end

    def pending?
      !MigrationRecord.exists?(version: version)
    end

    def run
      ActiveRecord::Base.connection.transaction do
        logger.info "Running data migration #{version}: #{name}"

        begin
          instance_eval File.read(path), path
          MigrationRecord.create!(version: version)
          logger.info "Migration complete"
        rescue => e
          logger.error "Migration failed due to #{e}"
          raise ActiveRecord::Rollback
        end

        logger.info "\n"
      end
    end

    private

    attr_reader :path, :logger
  end
end
