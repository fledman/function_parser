module FunctionParser
  class AST
    attr_reader :source
    attr_reader :config

    def initialize(source, config)
      @source = source
      @config = config
    end

    def tokens
      @tokens ||= parse.tokens
    end

    def arguments
      @arguments ||= parse.variables
    end

    def compile
      @compiled ||= compile_ast(tokens)
    end

    def to_proc
      base = compile.deep_dup
      raise ParseError, "Could not prepare expression" unless base.prepared?
      one_arg = arguments.count == 1 ? arguments.first : false
      Proc.new { |args = {}|
        if args.kind_of?(Hash)
          arg_hash = args.with_indifferent_access
        elsif one_arg
          arg_hash = Hash[one_arg => args].with_indifferent_access
        else
          raise ArgumentError, "Expected arguments to be passed as a hash"
        end
        result = base.execute(arg_hash)
        args.clear.merge!(arg_hash) if args.kind_of?(Hash)
        result
      }
    end

    private

    def parse
      @parse ||= Parser.new(config).parse(source)
    end

    def compile_ast(expr)
      recurse = expr.map{ |ele|
        case ele
        when Array then compile_ast(ele)
        when Expression::Operator then ele.dup
        else ele
        end
      }
      ordered = recurse.
        each_with_index.
        select{ |t,i|
          Expression::Operator === t && !t.prepared?
        }.
        each_with_index.
        sort_by{ |(t,ei),oi|
          [t.precedence,oi*(t.associativity == :L ? 1 : -1)]
        }
      tracker = recurse.dup
      nonassociative = Set.new
      ordered.each do |(op,ind_expr),ind_op|
        add_arg(op.associativity,ind_expr,tracker,op)
        if op.arity == 2
          other = op.associativity == :L ? :R : :L
          add_arg(other,ind_expr,tracker,op)
        end
        raise PrecedenceError, %{
          operation is not ready: #{op.inspect}
        }.squish unless op.prepared?
        if op.associativity == :N
          test_nonassociative(op,nonassociative)
          nonassociative << op.object_id
        end
      end
      compiled = tracker.reject{ |t| t == NULL }
      if compiled.size == 1
        ele = compiled.first
        return ele if ele.kind_of?(Expression::Operator)
        ident = Expression::Identity.new(ele)
        return ident if ident.prepared?
      end
      raise ParseError, %{
        The expression is malformed; finished with `#{compiled.inspect}`
      }.squish
    end

    def add_arg(assoc,start,expr,op)
      case assoc
      when :L
        set = op.method(:left=)
        iter = -1
      when :R,:N
        set = op.method(:right=)
        iter = 1
      else
        raise PrecedenceError, %{
          Unexpected associativity: `#{assoc}` for `#{op.name}`
        }.squish
      end
      ind = bounds_check(expr.length,start+iter)
      while expr[ind] == NULL
        ind = bounds_check(expr.length,ind+iter)
      end
      set.call(expr[ind])
      expr[ind] = NULL
      ind
    end

    def bounds_check(length, ind)
      if ind < 0 || ind >= length
        raise PrecedenceError, %{
          Operator argument out of bounds: #{ind} not in (0...#{length})
        }.squish
      end
      ind
    end

    def test_nonassociative(op, done)
      na = [op.left,op.right].compact.select{ |lr|
        Expression::Operator === lr &&
          lr.associativity == :N &&
            done.include?(lr.object_id) &&
              lr.precedence == op.precedence
      }
      if na.count > 0
        msg = "Nonassociative operators must be manually grouped:"
        msg << " #{op.name} <- "
        msg << na.map(&:name).inspect
        raise PrecedenceError, msg
      end
    end

  end
end
