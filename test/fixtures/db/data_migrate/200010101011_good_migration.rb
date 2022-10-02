ActiveRecord::Base.connection.execute(<<-SQL)
  SELECT current_timestamp;
SQL

after_commit do
  puts MonarchMigrate::VERSION
  puts ":after_commit did run"
end
