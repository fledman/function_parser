# Require all *.rb files in a given path,
# starting with those matching ordered
def ordered_require(ordered, *path)
  nOrd = ordered.count
  hash = Hash[ordered.each_with_index.to_a]
  files = Dir.glob(File.join(*path, '*.rb'))
  files.sort_by{ |file|
    bn = File.basename(file)
    hash[bn] || nOrd
  }.each { |f|
    require f
  }
end

## Standard Library and Gems
require 'set'
require 'stringio'
require 'irb/ruby-lex'
# activesupport usage
#  - Hash#with_indifferent_access
#  - String#squish
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string/filters'
## Get the path to this file
fp = File.expand_path(File.dirname(__FILE__))
## Info
require_relative 'version'
require_relative 'errors'
## Tokenization
require_relative 'tokens'
require_relative 'precedence'
## Expression
ordered = ['operator.rb']
ordered_require(ordered, fp, 'expression')
## Parser
require_relative 'parse_tree'
require_relative 'lexer'
require_relative 'parser'
## Grammar
ordered = ['configurable.rb', 'operations.rb']
ordered_require(ordered, fp, 'grammar')
## Config
require_relative 'config'
## AST
require_relative 'ast'
