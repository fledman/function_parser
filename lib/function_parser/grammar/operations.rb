module FunctionParser
  module Grammar
    class Operations
      attr_reader :tokens

      def initialize(*ops)
        raise ArgumentError, %{
          Operations Grammar requires at least one operator
        }.squish if opts.empty?
        @tokens = Token.operators(*ops)
        @tokens.freeze
        @operations = ops
      end

      def parse(token, lexer, pt)
        pt << Expression::Operator.new(token.name)
      end

    end
  end
end
