module FunctionParser
  class BaseError < StandardError; end
  class InvalidSymbol < BaseError; end
  class InvalidOperator < BaseError; end
  class InvalidRegexp < BaseError; end
  class UnexpectedToken < BaseError; end
  class ParenthesesMismatch < BaseError; end
  class PrecedenceError < BaseError; end
  class ParseError < BaseError; end
  class UndefinedVariable < BaseError; end
  class ConfigError < BaseError; end
end
