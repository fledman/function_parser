module FunctionParser
  module Grammar
    class Assignment
      attr_reader :tokens

      def initialize
        @tokens = Array(Tokens.operators('='))
        @tokens.freeze
      end

      def parse(token, lexer, pt)
        pt << Expression::Assignment.new
      end

    end
  end
end
