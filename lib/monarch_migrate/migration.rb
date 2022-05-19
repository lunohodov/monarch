# frozen_string_literal: true

module MonarchMigrate
  class Migration
    def initialize(path)
      @path = path.to_s
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

    def run(io = nil)
      io ||= File.open(File::NULL, "w")

      ActiveRecord::Base.connection.transaction do
        io.puts "Running data migration #{version}: #{name}"

        begin
          instance_eval File.read(path), path
          MigrationRecord.create!(version: version)
          io.puts "Migration complete"
        rescue => e
          io.puts "Migration failed due to #{e}"
          raise ActiveRecord::Rollback
        end

        io.puts
      end
    end

    private

    attr_reader :path
  end
end
