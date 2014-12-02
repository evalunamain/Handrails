require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 03_associatable to write ::assoc_options
  # has_one :house :through human source:owner
  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      target_class = through_options.model_class
      source_options = target_class.assoc_options[source_name]

      source_table = source_options.table_name
      through_table = through_options.table_name

      source_pk = source_table.primary_key
      through_pk = through_table.primary_key

      source_fk = source_table.foreign_key
      through_fk = through_table.foreign_key


      objects = DBConnection.execute(<<-SQL, self.primary_key)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}.*
        JOINS
          #{source_table}
          ON
          #{source_table}.#{source_pk} = #{through_table}.#{through_fk}
        WHERE
          #{through_table}.#{through_pk} = ?
      SQL

    p objects
    end
  end
end
