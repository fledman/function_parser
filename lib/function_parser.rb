require_relative 'function_parser/requirements'

module FunctionParser
  def self.create(source)
    config = Config.new.
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
    AST.new(source, config)
  end
end
