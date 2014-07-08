module FunctionParser
  class ParseTree
    include Enumerable

    def initialize
      @stack = []
      @expr = []
      @variables = {}
    end

    def <<(val)
      @expr << val
      self
    end

    def concat(ary)
      ary.each { |x| @expr << x }
      self
    end

    def open!
      @stack.push(@expr)
      @expr = []
      true
    end

    def close!
      prev = @stack.pop
      return false unless prev
      prev << @expr unless @expr.empty?
      @expr = prev
      true
    end

    def closed?
      stack.empty?
    end

    def variable(name)
      @variables[name] ||= Expression::Variable.new(name)
    end

    def variables
      @variables.keys.map(&:to_sym)
    end

    def tokens
      @expr.dup
    end

    def each &block
      raise ParseError, %{
        Cannot iterate over a ParseTree
        while it is still open!
      }.squish unless closed?
      @expr.each do |x|
        if block_given?
          block.call(x)
        else
          yield(x)
        end
      end
    end

  end
end
