require 'date'
require_relative 'lib/function_parser/version'

Gem::Specification.new do |s|
  s.name      = 'function_parser'
  s.version   = FunctionParser::VERSION
  s.platform  = Gem::Platform::RUBY
  s.date      = Date.today.to_s

  s.summary     = "Safely parse strings into Ruby procs"
  s.description = ""

  s.authors   = ["David Feldman"]
  s.email     = "dbfeldman@gmail.com"

  s.license   = "MIT"
  s.homepage  = "https://github.com/fledman/function_parser"

  s.files = Dir[
    'Rakefile', 'README*', 'LICENSE*', '{lib,test}/**/*'
  ] & `git ls-files -z`.split("\x0")

  s.require_paths = ["lib"]

  s.add_dependency 'activesupport', '~> 3.2'
end
