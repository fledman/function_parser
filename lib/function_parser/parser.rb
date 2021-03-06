module FunctionParser
  class Parser

    def initialize(config)
      @config = config
    end

    def parse(source)
      lexer = Lexer.new(source)
      token_map = @config.token_map
      pt = ParseTree.new
      while token = lexer.advance
        if grammar = token_map[token.class]
          grammar.parse(token, lexer, pt)
        else
          raise UnexpectedToken, %{
            The chosen configuration of FunctionParser
            does not support #{token.class}
            (see position #{token.seek})
          }.squish
        end
      end
      raise ParenthesesMismatch, %{
        Expression has an unclosed parentheses!
      }.squish unless pt.closed?
      return pt
    rescue RubyLex::SyntaxError => se
      raise ParseError, se.message
    end

  end
end
