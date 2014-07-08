module FunctionParser
  module Grammar
    class Skip
      attr_reader :tokens

      def initialize
        @tokens = [
          Tokens::SPACE,
          Tokens.lexicals(';')
        ].freeze
      end

      def parse(token, lexer, pt)
        return
      end

    end
  end
end
