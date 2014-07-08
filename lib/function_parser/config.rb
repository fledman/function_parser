module FunctionParser
  class Config

    def initialize
      @enabled = Hash.new
    end

    def grammars
      @enabled.values
    end

    [ :arithmetic, :power, :modular,
      :equality, :comparison, :match,
      :logical, :bitwise, :shift
    ].each do |category|
      define_method(category) { |on|
        if on
          @enabled[category] ||= begin
            ops = Tokens.const_get(category.to_s.upcase).keys
            Grammar::Operations.new(*ops)
          end
        else
          @enabled.delete(category)
        end
      }
    end

    def inequality(on, strict = nil)
      strict = strict.nil? ? [true,false] : [strict]
      strict.each do |b|
        key = "inequality_s#{b.to_s[0]}".to_sym
        if on
          @enabled[key] ||= Grammar::Inequality(b)
        else
          @enabled.delete(key)
        end
      end
    end

  end
end
