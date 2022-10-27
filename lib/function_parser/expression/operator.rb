module FunctionParser
  module Expression
    class Operator
      attr_accessor :name, :precedence
      attr_accessor :arity, :associativity
      attr_accessor :left, :right
      def initialize(n)
        self.name = n
        props = Precedence.lookup(n)
        self.precedence = props[0]
        self.associativity = props[1]
        self.arity = props[2]
        self.left = self.right = NULL
      end
      def prepared?
        raise PrecedenceError, "Non-Integer precedence: `#{precedence}`" unless (Integer(precedence) rescue false)
        raise PrecedenceError, "Unexpected arity: `#{arity}`" unless [1,2].include?(arity)
        raise PrecedenceError, "Unexpected associativity: `#{associativity}`" unless [:L,:R,:N].include?(associativity)
        case arity
        when 1
          case associativity
          when :L
            expected, other = left, right
          when :R,:N
            expected, other = right, left
          end
          raise PrecedenceError, "Wrong side of arity=1 operator is populated!" if other != NULL
          return expected != NULL
        when 2
          return right != NULL && left != NULL
        end
      end
      def deep_dup
        dupl = self.dup
        if Operator === left
          dupl.left = left.deep_dup
        end
        if Operator === right
          dupl.right = right.deep_dup
        end
        dupl
      end
      def execute(arg_hash)
        raise ParseError, "Operator is not ready to execute" unless prepared?
        operands = case arity
        when 1
          associativity == :L ? [left] : [right]
        when 2
          [left,right]
        end
        resolved = operands.map{|o|resolve(o,arg_hash)}
        compute(resolved)
      end
      def to_s
        [wrap(left),translate(name),wrap(right)].compact.join.strip
      end
      private
      def compute(parts)
        if name == '&&' && parts.count == 2
          parts[0] && parts[1]
        elsif name == '||' && parts.count == 2
          parts[0] || parts[1]
        else
          func = name.to_sym
          base = parts.shift
          raise InvalidOperator, "You cannot apply #{name} to #{base}" unless base.respond_to?(func)
          base.send(func,*parts)
        end
      end
      def wrap(input)
        if Operator === input
          "(#{input.to_s})"
        else
          input.to_s
        end
      end
      def translate(op)
        return '-' if op == '-@'
        " #{op} "
      end
      def resolve(operand,arg_hash)
        case operand
        when Operator
          operand.execute(arg_hash)
        when Variable
          raise UndefinedVariable, "`#{operand.name}` is not defined" unless arg_hash.has_key?(operand.name)
          arg_hash[operand.name]
        else
          operand
        end
      end
    end
  end
end
