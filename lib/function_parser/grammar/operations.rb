module FunctionParser
  module Grammar
    class Operations
      attr_reader :tokens

      def initialize(*ops)
        raise ArgumentError, %{
          Operations Grammar requires at least one operator
        }.squish if ops.empty?
        @tokens = Array(Tokens.operators(*ops))
        @tokens.freeze
        @operations = ops
      end

      def parse(token, lexer, pt)
        if should_be_unary?(token, pt)
          pt << Expression::Operator.new(token.name + '@')
        else
          pt << Expression::Operator.new(token.name)
        end
      end

      def should_be_unary?(token, pt)
        if RubyToken::TkMINUS === token
          return true if pt.current_expression_empty?
          prior = pt.previous_element_in_current_expression
          return true if prior.is_a?(Expression::Operator)
        end
        false
      end

    end
  end
end
