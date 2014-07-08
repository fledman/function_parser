module FunctionParser
  module Expression
    class Identity < Operator
      alias :to_s :left
      def initialize(val)
        self.name = 'instance_eval'
        self.precedence = -1
        self.associativity = :L
        self.arity = 2
        self.left = val
        self.right = "self"
      end
    end
  end
end
