module FunctionParser
  module Grammar
    module Configurable

      def prepare(allowed)
        @tokens = Set.new.freeze
        Array(allowed).each { |k| allow(k, true) }
      end

      def allow(key, on = true)
        check_key(key)
        token = Tokens.operands(key)
        raise ArgumentError, %{
          Could not find token for `#{key.inspect}`!
        }.squish unless token
        op = on ? :+ : :-
        @tokens = @tokens.send(op, [token])
        @tokens.freeze
      end

      def disabled?
        @tokens.empty?
      end

      private

      def check_key(key)
        raise NotImplementedError
      end

    end
  end
end
