# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'provise'

Gem::Specification.new do |gem|
  gem.name          = "provise"
  gem.version       = Provise::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.authors       = ["Felipe Sabino"]
  gem.email         = "felipe@sabino.me"
  gem.description   = "CLI for re-signing iOS Apps (.ipa files)"
  gem.summary       = "Re-sign iOS Apps (.ipa files)"
  gem.homepage      = ""

  gem.add_dependency "commander", "~> 4.1.2"

  gem.files         = `git ls-files`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]
end
