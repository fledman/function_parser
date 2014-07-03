require 'irb/ruby-token'

module FunctionParser
  class Tokens

    ######### Operands ##########

    SYMBOL = {
      Symbol => RubyToken::TkSYMBEG
    }

    NUMBER = {
      Float   => RubyToken::TkFLOAT,
      Integer => RubyToken::TkINTEGER
    }

    STRING = {
      String => RubyToken::TkSTRING
    }

    REGEXP = {
      Regexp => RubyToken::TkREGEXP
    }

    BOOLEAN = {
      true  => RubyToken::TkTRUE,
      false => RubyToken::TkFALSE
    }

    NIL = {
      nil => RubyToken::TkNIL
    }

    def self.operands(*select)
      memo_with_inverse(:operands, select) {
        [ SYMBOL, NUMBER, STRING,
          REGEXP, BOOLEAN, NIL
        ].reduce(:merge)
      }
    end

    ######### Operators #########

    ARITHMETIC = {
      '+' => RubyToken::TkPLUS,
      '-' => RubyToken::TkMINUS,
      '*' => RubyToken::TkMULT,
      '/' => RubyToken::TkDIV
    }

    RELATIONAL = {
      '>'   => RubyToken::TkGT,
      '<'   => RubyToken::TkLT,
      '>='  => RubyToken::TkGEQ,
      '<='  => RubyToken::TkLEQ,
      '=='  => RubyToken::TkEQ,
      '===' => RubyToken::TkEQQ,
      '!='  => RubyToken::TkNEQ
    }

    COMPARISON = {
      '<=>' => RubyToken::TkCMP
    }

    LOGICAL = {
      '&&' => RubyToken::TkANDOP,
      '||' => RubyToken::TkOROP,
      '!'  => RubyToken::TkNOTOP
    }

    MATCH = {
      '=~' => RubyToken::TkMATCH,
      '!~' => RubyToken::TkNMATCH
    }

    BITWISE = {
      '|' => RubyToken::TkBITOR,
      '^' => RubyToken::TkBITXOR,
      '&' => RubyToken::TkBITAND,
      '~' => RubyToken::TkBITNOT
    }

    SHIFT = {
      '<<' => RubyToken::TkLSHFT,
      '>>' => RubyToken::TkRSHFT
    }

    MODULAR = {
      '%' => RubyToken::TkMOD
    }

    POWER = {
      '**' => RubyToken::TkPOW
    }

    UNARY = {
      '-@' => RubyToken::TkUMINUS
    }

    ASSIGNMENT = {
      '=' => RubyToken::TkASSIGN
    }

    def self.operators(*select)
      memo_with_inverse(:operators, select) {
        [ ARITHMETIC, RELATIONAL,
          COMPARISON, LOGICAL,
          MATCH, BITWISE, SHIFT,
          MODULAR, POWER, UNARY,
          ASSIGNMENT
        ].reduce(:merge)
      }
    end

    ######### Lexicals ##########

    PUNCTUATION = {
      ';' => RubyToken::TkSEMICOLON,
      '?' => RubyToken::TkQUESTION,
      ':' => RubyToken::TkCOLON,
      ',' => RubyToken::TkCOMMA,
      '.' => RubyToken::TkDOT
    }

    BRACKETS = {
      '(' => RubyToken::TkLPAREN,
      ')' => RubyToken::TkRPAREN,
      '[' => RubyToken::TkLBRACK,
      ']' => RubyToken::TkRBRACK,
      '{' => RubyToken::TkLBRACE,
      '}' => RubyToken::TkRBRACE
    }

    def self.lexicals(*select)
      memo_with_inverse(:lexicals, select) {
        [ BRACKETS, PUNCTUATION ].reduce(:merge)
      }
    end

    ######### One-Offs ##########

    SPACE = RubyToken::TkSPACE

    IDENTIFIER = RubyToken::TkIDENTIFIER

    ######### Helpers ##########

    private

    def self.memo_with_inverse(key, args)
      raise ArgumentError, "Block is required!" unless block_given?
      @memo ||= {}
      @memo[key] ||= {}
      @memo[key]['forward'] ||= begin
        map = yield
        raise ArgumentError, "Block must yield a hash!" unless map.is_a?(Hash)
        map
      end
      @memo[key]['inverse'] ||= begin
        inverse = @memo[key]['forward'].invert
        if inverse.count != @memo[key]['forward'].count
          @memo[key] = nil
          raise ArgumentError, "Token hash is not one-to-one!"
        end
        inverse
      end
      return @memo[key]['forward'] if args.empty?
      vals = args.map { |arg|
        which, arg = token_class(arg)
        if @memo[key][which].has_key?(arg)
          @memo[key][which][arg]
        else
          raise ArgumentError, %{
            #{which}-#{key} mapping does not
            have a value for `#{arg.inspect}`
          }.strip.split.join(' ')
        end
      }
      vals.count == 1 ? vals.first : vals
    end

    def self.token_class(arg)
      case
      when arg.is_a?(Class) && arg <= RubyToken::Token
        return 'inverse', arg
      when arg.is_a?(RubyToken::Token)
        return 'inverse', arg.class
      else
        return 'forward', arg
      end
    end

  end
end
