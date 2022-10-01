ActiveRecord::Base.connection.execute(<<-SQL)
  SELECT some_non_existing_function;
SQL
