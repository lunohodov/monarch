class CreateDataMigrationRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :data_migration_records do |t|
      t.string :version, null: false
      t.timestamps
    end

    add_index :data_migration_records, :version, unique: true
  end
end
