module FunctionParser
  class Lexer
    attr_reader :source

    def initialize(source)
      @position = -1
      @tokens = []
      @source = source

      @lexer = RubyLex.new
      @lexer.set_input(StringIO.new(source))
      @lexer.skip_space = false
      @lexer.exception_on_syntax_error = true
    end

    def advance
      @position = -1
      return @lexer.token if @tokens.empty?
      @tokens.shift
    end

    def peek
      tok = @tokens[@position + 1]
      if !tok && (token = @lexer.token)
        @tokens << token
      end
      tok = @tokens[@position + 1]
      @position += 1 if tok
      tok
    end

  end
end
