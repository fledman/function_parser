require_relative 'function_parser/requirements'

module FunctionParser
  def self.default_configuration
    Config.new.
      operations(:all,true).
      operations(:match,false).
      variables.
      parentheses.
      symbols.
      strings.
      floats.
      integers.
      booleans.
      nil
  end
  def self.create(source, config = default_configuration)
    AST.new(source, config)
  end
end
