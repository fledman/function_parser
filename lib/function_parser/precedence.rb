module FunctionParser
  class Precedence
    def self.lookup(op)
      case op
      when '!','~' then [0,:R,1]
      when '**' then [1,:R,2]
      when '-@' then [2,:R,1]
      when '*','/','%' then [3,:L,2]
      when '+','-' then [4,:L,2]
      when '>>','<<' then [5,:L,2]
      when '&' then [6,:L,2]
      when '^','|' then [7,:L,2]
      when '<=','<','>','>=' then [8,:L,2]
      when '==','===','!=', '=~', '!~', '<=>' then [9,:N,2]
      when '&&' then [10,:L,2]
      when '||' then [11,:L,2]
      when '=' then [12,:N,2]
      else
        raise InvalidOperator, "Do not know the precedence of `#{op}`"
      end
    end
  end
end
