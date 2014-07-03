lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'function_parser/version'

Gem::Specification.new do |s|
  s.name      = 'function_parser'
  s.version   = FunctionParser::VERSION
  s.platform  = Gem::Platform::RUBY
  s.date      = Date.today.to_s

  s.authors   = ["David Feldman"]
  s.email     = "dbfeldman@gmail.com"

  s.license   = "MIT"
  s.homepage  = "https://github.com/fledman/function_parser"

  s.files     = `git ls-files -z`.split("\x0")

  s.require_paths = ["lib"]

  s.add_dependency 'active_support', '>= 3.0.0'

  s.add_development_dependency "rake"
end
