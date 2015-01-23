require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    cols = params.keys
    values = params.values
    where_sql = cols.map{ |col| "#{col} = ?"}.join(" AND ")
    objects = []

    results = DBConnection.execute(<<-SQL, *values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_sql}
      SQL

    results.each do |result|
      objects <<  self.new(result)
    end

    objects
  end
end

class SQLObject
  extend Searchable
end
