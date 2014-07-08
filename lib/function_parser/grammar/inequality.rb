module FunctionParser
  module Grammar
    class Inequality < Operations

      def initialize(strict)
        check_strict(strict)
        ops =   strict ?
            ['<', '>'] :
          ['<=', '>=']
        super(*ops)
      end

      private
      def check_strict(strict)
        valid = [true,false].include?(strict)
        raise ArgumentError, %{
          strict must be true or false
        }.squish unless valid
      end

    end
  end
end
