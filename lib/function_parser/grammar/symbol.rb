module FunctionParser
  module Grammar
    class Symbol
      attr_reader :tokens

      def initialize
        @tokens = Array(Tokens.operands(::Symbol))
        @tokens.freeze
      end

      def parse(token, lexer, pt)
        rest = lexer.advance
        raise InvalidSymbol, %{
          Invalid symbol at position #{token.seek}
        }.squish unless rest.kind_of?(Tokens::IDENTIFIER)
        pt << rest.name.to_sym
      end

    end
  end
end
