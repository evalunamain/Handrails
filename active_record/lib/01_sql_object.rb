require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    cols = DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

  end

  def self.finalize!
    self.columns.each do |col_name|
      define_method("#{col_name}") do
        self.attributes[col_name]
      end

      define_method("#{col_name}=") do |value|
        self.attributes[col_name] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    records = DBConnection.execute(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL

    self.parse_all(records)
  end

  def self.parse_all(results)
    self_class = self
    @objects = []
    results.each do |result|
      @objects << self.new(result)
    end

    @objects
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
      #{self.table_name}.id = ?
    SQL

    result.empty? ? nil : self.new(result.first)

  end

  def initialize(params = {})
    params.each do |param|
      attr_name = param.first.to_sym
      attr_value = param[1]
      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end
      self.send("#{attr_name}=", attr_value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    values = self.class.columns.map{ |el| self.send(el) }
  end

  def insert
    columns = self.class.columns
    col_names = columns.join(",")
    question_marks = (["?"] * columns.length).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id

  end

  def update
    set_sql = self.class.columns.map { |col| "#{col} = ?" }

    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_sql.join(", ")}
      WHERE
        id = ?
      SQL
  end

  def save
    self.id ? self.send(:update) : self.send(:insert)
  end
end
