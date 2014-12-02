require_relative '02_searchable'
require 'active_support/inflector'

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular 'human', 'humans'
end

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    self.class_name.underscore.pluralize
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})

    defaults = {
      :foreign_key => "#{name}_id".to_sym,
      :primary_key => "id".to_sym,
      :class_name => "#{name.camelize}"}

    options = defaults.merge(options)


    options.keys.each do |option|
      self.send("#{option}=", options[option])
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})

    defaults = {
      :foreign_key => "#{self_class_name.underscore}_id".to_sym,
      :primary_key => "id".to_sym,
      :class_name => "#{name.camelize.singularize}"}

    options = defaults.merge(options)

    options.keys.each do |option|
      self.send("#{option}=", options[option])
    end
  end
end

module Associatable
  # Phase IIIb

  def belongs_to(name, options = {})
    self.assoc_options[name] = options
    self.assoc_options
    options = BelongsToOptions.new(name.to_s, options)


    define_method(name) do
      fk_value = self.send(options.foreign_key)
      target_class = options.model_class
      target_class.where({options.primary_key => fk_value}).first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = options
    p self.assoc_options
    options = HasManyOptions.new(name.to_s, self.to_s, options)


      define_method(name) do
        pk_value = self.send(options.primary_key)
        target_class = options.model_class
      target_class.where({options.foreign_key => pk_value})
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable
end
