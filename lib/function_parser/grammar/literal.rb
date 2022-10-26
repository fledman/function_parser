module FunctionParser
  module Grammar
    class Literal
      include Configurable
      attr_reader :tokens

      def initialize(allowed = [])
        prepare(allowed)
      end

      def parse(token, lexer, pt)
        after = lexer.peek
        value = after ? lexer.source[token.seek...after.seek]
                      : lexer.source[token.seek..-1]
        pt.concat(replace(token,value))
      end

      private

      def check_key(key)
        valid = key.is_a?(Class)
        raise ArgumentError, %{
          Key must be a class!
        }.squish unless valid
      end

      def replace(token, string)
        case token
        when *Tokens.operands(Float, Integer)
          replace_number(token, string)
        when Tokens.operands(String)
          [string[1...-1]]
        when Tokens.operands(Regexp)
          replace_regexp(token, string)
        else
          raise UnexpectedToken, %{
            Expected a string, number, or
            regexp at position #{token.seek}
          }.squish
        end
      end

      def replace_number(token, string)
        type = Tokens.operands(token).name.to_sym
        n = Kernel.public_send(type, string)
        n < 0 ? [Expression::Operator.new('-@'), -n] : [n]
      end

      def replace_regexp(token, string)
        close = string.rindex('/')
        if close && close != 0 && string[0] == '/'
          flags = string[close+1..-1]
          options = flags.each_char.reduce(0) { |s,c|
            i = "ixm".index(c)
            s + (i ? 2**i : 0)
          }
          [Expression::Regexp.new(string[1...close], options)]
        else
          raise InvalidRegexp, %{
            `#{string}` is not a valid regular expression
          }.squish
        end
      end

    end
  end
end
