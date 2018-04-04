# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
lib = File.expand_path('../lib', __FILE__)
puts "#{lib}"
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'middleman-email/pkg-info'


Gem::Specification.new do |s|
  s.name        = "middleman-email"
  s.version     = "0.0.2"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Your Name"]
  s.email       = ["email@example.com"]
  # s.homepage    = "http://example.com"
  s.summary     = %q{A short summary of your extension}
  s.description = %q{A longer description of your extension}

  s.files         = `git ls-files -z`.split("\0")
  s.test_files    = `git ls-files -z -- {test,spec,features}/*`.split("\0")
  s.executables   = `git ls-files -z -- bin/*`.split("\0").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # The version of middleman-core your extension depends on
  s.add_runtime_dependency("middleman-core", [">= 3.3.12"])
  s.add_runtime_dependency("premailer")
  s.add_runtime_dependency("nokogiri")
  s.add_runtime_dependency("mail")



  # Additional dependencies
  # s.add_runtime_dependency("gem-name", "gem-version")
end
