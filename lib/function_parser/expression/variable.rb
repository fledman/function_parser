module FunctionParser
  module Expression
    class Variable
      attr_accessor :name
      alias :to_s :name
      def initialize(n)
        self.name = n
      end
    end
  end
end
