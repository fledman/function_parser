module FunctionParser
  class Config

    def initialize
      @enabled = Hash[skip: Grammar::Skip.new]
    end

    def grammars
      @enabled.values
    end

    def operations(group, on, *args)
      group = group.to_sym
      groups = [
        :arithmetic, :power, :modular,
        :equality, :comparison, :match,
        :logical, :bitwise, :shift
      ]
      incl = groups.include?(group)
      if incl
        on_off(on,group) {
          cat = group.to_s.upcase
          ops = Tokens.const_get(cat).keys
          Grammar::Operations.new(*ops)
        }
      elsif group == :inequality
        raise ConfigError, %{
          operations(:inequality, on, ...) takes
          only one argument, got `#{args.inspect}`
        }.squish if args.count > 1
        strict = args.empty? ? [true,false] : args
        strict.each do |b|
          key = "inequality_s#{b.to_s[0]}".to_sym
          on_off(on,key) { Grammar::Inequality.new(b) }
        end
        self
      elsif group == :all && args.empty?
        groups.each{ |i| operations(i, on) }
        operations(:inequality, on)
      else
        raise ConfigError, %{
          Unknown operation group `#{group.inspect}`
          with args `#{args.inspect}`
        }.squish
      end
    end

    def assignment(on = true)
      on_off(on,:assignment) {
        Grammar::Assignment.new
      }
    end

    def variables(on = true)
      on_off(on,:variables) {
        Grammar::Variable.new
      }
    end

    def parentheses(on = true)
      on_off(on,:parentheses) {
        Grammar::Parens.new
      }
    end

    def symbols(on = true)
      on_off(on,:symbols) {
        Grammar::Symbol.new
      }
    end

    def booleans(on = true)
      configurable(
        on, :nilbool, Grammar::NilBoolean,
        true, false
      )
    end

    def nil(on = true)
      configurable(
        on, :nilbool, Grammar::NilBoolean,
        nil
      )
    end

    [Float, Integer, String, Regexp].each do |klass|
      key = (klass.to_s.downcase << 's').to_sym
      define_method(key) do |on = true|
        configurable(
          on, key, Grammar::Literal,
          klass
        )
      end
    end

    alias_method :regular_expressions, :regexps

    private

    def on_off(on, key)
      if on
        @enabled[key] ||= yield
      else
        @enabled.delete(key)
      end
      self
    end

    def configurable(on, key, klass, *types)
      @enabled[key] ||= klass.new
      types.each do |type|
        @enabled[key].allow(type, on)
      end
      @enabled.delete(key) if @enabled[key].disabled?
      self
    end

  end
end
