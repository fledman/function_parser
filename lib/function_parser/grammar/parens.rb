module FunctionParser
  module Grammar
    class Parens
      attr_reader :tokens

      def initialize
        @tokens = Tokens.lexicals('(', 'f(', ')').freeze
      end

      def parse(token, lexer, pt)
        case token
        when *Tokens.lexicals('(', 'f(')
          pt.open!
        when Tokens.lexicals(')')
          success = pt.close!
          raise ParenthesesMismatch, %{
            Closing parenthesis without
            opening at position #{token.seek}
          }.squish unless success
        end
      end

    end
  end
end
