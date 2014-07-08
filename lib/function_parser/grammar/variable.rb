module FunctionParser
  module Grammar
    class Variable
      attr_reader :tokens

      def initialize
        @tokens = Array(Tokens::IDENTIFIER)
        @tokens.freeze
      end

      def parse(token, lexer, pt)
        pt << pt.variable(token.name)
      end

    end
  end
end
