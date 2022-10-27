# frozen_string_literal: true

RSpec.describe 'Bitwise Operations' do
  # derived from https://github.com/ruby/spec/blob/master/core/integer/

  let(:config) do
    FunctionParser::Config.new
    .integers
    .parentheses
    .operations(:arithmetic, true)
    .operations(:bitwise, true)
    .operations(:power, true)
    .operations(:shift, true)
  end
  
  let(:ast) { FunctionParser::AST.new(source, config) }

  subject { ast.to_proc.call }

  {
    '256 & 16'         => 0,
    '2010 & 5'         => 0,
    '65535 & 1'        => 1,
    '(1 << 33) & -1'   => (1 << 33),
    '-1 & (1 << 33)'   => (1 << 33),
    '(-(1<<33)-1) & 5' => 5,
    '5 & (-(1<<33)-1)' => 5,
    '-5 & -1'          => -5,
    '-3 & -4'          => -4,
    '-12 & -13'        => -16,
    '-13 & -12'        => -16,
    '-1 & 2**64'       => 18446744073709551616,
    '1 | 0'            => 1,
    '5 | 4'            => 5,
    '5 | 6'            => 7,
    '248 | 4096'       => 4344,
    '(1 << 33) | -1'   => -1,
    '-1 | (1 << 33)'   => -1,
    '(-(1<<33)-1) | 5' => -8589934593,
    '5 | (-(1<<33)-1)' => -8589934593,
    '-5 | -1'          => -1,
    '-3 | -4'          => -3,
    '-12 | -13'        => -9,
    '-13 | -12'        => -9,
    '-1 | 2**64'       => -1,
    '3 ^ 5'            => 6,
    '-2 ^ -255'        => 255,
    '(1 << 33) ^ -1'   => -8589934593,
    '-1 ^ (1 << 33)'   => -8589934593,
    '(-(1<<33)-1) ^ 5' => -8589934598,
    '5 ^ (-(1<<33)-1)' => -8589934598,
    '-5 ^ -1'          => 4,
    '-3 ^ -4'          => 1,
    '-12 ^ -13'        => 7,
    '-13 ^ -12'        => 7,
    '-1 ^ 2**64'       => -18446744073709551617,
    '2 >> 1'           => 1,
    '-2 >> 1'          => -1,
    '-7 >> 1'          => -4,
    '-42 >> 2'         => -11,
    '1 >> -1'          => 2,
    '-1 >> -1'         => -2,
    '0 >> 1'           => 0,
    '1 >> 0'           => 1,
    '-1 >> 0'          => -1,
    '3 >> 2'           => 0,
    '7 >> 3'           => 0,
    '127 >> 7'         => 0,
    '7 >> 32'          => 0,
    '7 >> 64'          => 0,
    '-3 >> 2'          => -1,
    '-7 >> 3'          => -1,
    '-127 >> 7'        => -1,
    '-7 >> 32'         => -1,
    '-7 >> 64'         => -1,
    '1 << 1'           => 2,
    '-1 << 1'          => -2,
    '-7 << 1'          => -14,
    '-42 << 2'         => -168,
    '2 << -1'          => 1,
    '-2 << -1'         => -1,
    '0 << 1'           => 0,
    '1 << 0'           => 1,
    '-1 << 0'          => -1,
    '3 << -2'          => 0,
    '7 << -3'          => 0,
    '127 << -7'        => 0,
    '7 << -32'         => 0,
    '7 << -64'         => 0,
    '-3 << -2'         => -1,
    '-7 << -3'         => -1,
    '-127 << -7'       => -1,
    '-7 << -32'        => -1,
    '-7 << -64'        => -1,
    '~0'               => -1,
    '~1221'            => -1222,
    '~-2'              => 1,
    '~-599'            => 598,
  }.each do |expr, result|
    context expr do
      let(:source) { expr }
      it { is_expected.to eql(result) }
    end
  end

  [
    '3 & 3.4',
    '3 | 3.4',
    '3 ^ 3.4',
    '3 >> nil',
    '3 >> "4"',
    '3 << nil',
    '3 << "4"',
  ].each do |expr|
    context expr do
      let(:source) { expr }

      def execute(conf)
        FunctionParser::AST.new(source, conf).to_proc.call
      end

      it 'raises UnexpectedToken with strict config' do
        expect { execute(config) }.to raise_error(FunctionParser::UnexpectedToken)
      end

      it 'raises TypeError with loose config' do
        expect { execute(FunctionParser.default_configuration.nil) }.to raise_error(TypeError)
      end
    end
  end
end
