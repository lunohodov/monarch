ActiveRecord::Base.connection.execute(<<-SQL)
  SELECT current_timestamp;
SQL
