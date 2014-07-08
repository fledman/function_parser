module FunctionParser
  module Grammar
    class NilBoolean
      include Configurable
      attr_reader :tokens

      def initialize(allowed = [])
        prepare(allowed)
      end

      def parse(token, lexer, pt)
        pt << Tokens.operands(token)
      end

      private

      def check_key(key)
        valid = [true,false,nil].include?(key)
        raise ArgumentError, %{
          Key must be true, false, or nil!
        }.squish unless valid
      end

    end
  end
end
