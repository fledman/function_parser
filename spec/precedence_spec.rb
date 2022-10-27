# frozen_string_literal: true

RSpec.describe 'Operator Precedence' do
  # derived from https://github.com/ruby/spec/blob/master/language/precedence_spec.rb

  let(:config) { FunctionParser.default_configuration }
  let(:ast)    { FunctionParser::AST.new(source, config) }

  subject { ast.to_proc.call }

  {
    '!!true'                 => true,
    '~~0'                    => 0,
    '--2'                    => 2,
    '2**2**3'                => 256,
    '-2**2'                  => -4,
    '2*1/2'                  => 1,
    '10/7/5'                 => 0,
    '101 % 55 % 7'           => 4,
    '50*20/7%42'             => 16,
    '2+2*2'                  => 6,
    '1+10/5'                 => 3,
    '2+10%5'                 => 2,
    '2-2*2'                  => -2,
    '1-10/5'                 => -1,
    '10-10%4'                => 8,
    '2-3-4'                  => -5,
    '4-3+2'                  => 3,
    '2<<1+2'                 => 16,
    '8>>1+2'                 => 1,
    '4<<1-3'                 => 1,
    '2>>1-3'                 => 8,
    '1 << 2 << 3'            => 32,
    '10 >> 1 >> 1'           => 2,
    '10 << 4 >> 1'           => 80,
    '4 & 2 << 1'             => 4,
    '2 & 4 >> 1'             => 2,
    '8 ^ 16 & 16'            => 24,
    '8 | 16 & 16'            => 24,
    '-~3**3'                 => 64,
    '10 <= 7 ^ 7'            => false,
    '10 < 7 ^ 7'             => false,
    '10 > 7 ^ 7'             => true,
    '10 >= 7 ^ 7'            => true,
    '10 <= 7 | 7'            => false,
    '10 < 7 | 7'             => false,
    '10 > 7 | 7'             => true,
    '10 >= 7 | 7'            => true,
    'false && 2 <=> 3'       => false,
    'false && 3 == false'    => false,
    'false && 3 === false'   => false,
    'false && 3 != true'     => false,
    'true || false && false' => true,
  }.each do |expr, result|
    context expr do
      let(:source) { expr }
      it { is_expected.to eql(result) }
    end
  end

  [
    '1 <=> 2 <=> 3',
    '1 == 2 == 3',
    '1 === 2 === 3',
    '1 != 2 != 3',
    '1 =~ 2 =~ 3',
    '1 !~ 2 !~ 3'
  ].each do |expr|
    context expr do
      let(:source) { expr }
      let(:config) { FunctionParser.default_configuration.operations(:match,true) }
      it 'raises an error due to non-associativity' do
        expect { subject }.to raise_error(FunctionParser::PrecedenceError, /Nonassociative/)
      end
    end
  end

end
