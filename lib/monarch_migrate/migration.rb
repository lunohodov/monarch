# frozen_string_literal: true

module MonarchMigrate
  class Migration
    def initialize(path)
      @path = path.to_s
      @after_commit_callback = nil
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

    def after_commit(&block)
      @after_commit_callback = block
    end

    def run
      ActiveRecord::Base.connection.transaction do
        puts "Running data migration #{version}: #{name}"

        begin
          instance_eval File.read(path), path
          MigrationRecord.create!(version: version)
          puts "Migration complete"
        rescue => e
          puts "Migration failed due to #{e}"
          # Deliberately raising ActiveRecord::Rollback does not
          # pass on the exception and the callback will be triggered
          raise
        end

        puts
      end

      after_commit_callback&.call
    end

    private

    attr_reader :path
    attr_reader :after_commit_callback
  end
end
