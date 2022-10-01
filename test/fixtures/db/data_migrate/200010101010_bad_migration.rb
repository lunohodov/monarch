ActiveRecord::Base.connection.execute(<<-SQL)
  SELECT some_non_existing_function;
SQL

after_commit do
  puts MonarchMigrate::VERSION
  puts ":after_commit did run"
end
