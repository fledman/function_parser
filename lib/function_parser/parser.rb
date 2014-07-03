module FunctionParser
  class Parser
    attr_reader :config

    def initialize(options = {})
      @config = options
      @config[:valid_ops] ||= Tokens.operators.reject{ |k,v| k == '=' }.values
    end

    def parse(source)
      lexer = RubyLex.new
      lexer.set_input(StringIO.new(source))
      lexer.skip_space = false
      lexer.exception_on_syntax_error = true
      stack = []
      expr = []
      last = nil
      variables = {}
      while token = lexer.token
        if last
          value = source[last.seek...token.seek]
          expr += replace(last,value)
          last = nil
        end
        case token
        when Tokens.operands(Symbol)
          rest = lexer.token
          unless rest.kind_of?(Tokens::IDENTIFIER)
            raise InvalidSymbol, "Invalid symbol at position #{token.seek}"
          end
          expr << rest.name.to_sym
        when *Tokens.operands(Float, Integer, String, Regexp)
          last = token
        when Tokens::IDENTIFIER
          expr << record(variables,token.name)
        when *Tokens.operands(true,false,nil)
          expr += replace(token,token.name)
        when *@config[:valid_ops]
          expr << Operator.new(token.name)
        when Tokens::SPACE, Tokens.lexicals(';') then next
        when Tokens.lexicals('(')
          stack.push(expr)
          expr = []
        when Tokens.lexicals(')')
          prev = stack.pop
          raise ParenthesesMismatch, %{
            Closing parenthesis without opening at position #{token.seek}
          }.squish unless prev
          prev << expr unless expr.empty?
          expr = prev
        when Tokens.operators('=')
          expr << Assignment.new
        else
          raise UnexpectedToken, "Got a null token" if token.nil?
          raise UnexpectedToken, %{
            FormulaParser does not support #{token.class}
            (see position #{token.seek})
          }.squish
        end
      end
      if last
        expr += replace(last,source[last.seek..-1])
      end
      raise ParenthesesMismatch, %{
        Expression has an unclosed parenthesis
      }.squish unless stack.empty?
      return expr, variables
    rescue RubyLex::SyntaxError => se
      raise ParseError, se.message
    end

    private

    def record(variables, name)
      variables[name] ||= Variable.new(name)
    end

    def replace(token, string)
      case token
      when *Tokens.operands(Float, Integer)
        type = Tokens.operands(token).name.to_sym
        n = Kernel.public_send(type, string)
        n < 0 ? [Operator.new('-@'), -n] : [n]
      when *Tokens.operands(true,false,nil)
        [Tokens.operands(token)]
      when Tokens.operands(String)
        [string[1...-1]]
      when Tokens.operands(Regexp)
        close = string.rindex('/')
        if close && close != 0 && string[0] == '/'
          flags = string[close+1..-1]
          options = flags.each_char.reduce(0) { |s,c|
            i = "ixm".index(c)
            s + (i ? 2**i : 0)
          }
          [Regexp.new(string[1...close], options)]
        else
          raise InvalidRegexp, %{
            `#{string}` is not a valid regular expression
          }.squish
        end
      else
        raise UnexpectedToken, "Got a null token" if token.nil?
        raise UnexpectedToken, %{
          Expected a string, boolean, number,
          regexp, or nil at position #{token.seek}
        }.squish
      end
    end

  end
end
