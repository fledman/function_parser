module FunctionParser
  module Expression
    class Assignment < Operator
      alias :var :left
      alias :val :right
      def initialize
        super('=')
        @set_val = false
      end
      def left=(set)
        raise ParseError, "#{set} is not a Variable" unless Variable === set
        super
      end
      def right=(set)
        @set_val = true
        super
      end
      def prepared?
        !!(var && Variable === var && var.name && @set_val)
      end
      def execute(arg_hash)
        raise ParseError, "Assignment is not ready to execute" unless prepared?
        arg_hash[var.name.to_sym] = resolve(val,arg_hash)
      end
      def to_s
        "#{var.name} = #{wrap(val)}"
      end
    end
  end
end
