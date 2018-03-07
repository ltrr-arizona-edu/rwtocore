# -*- coding: utf-8 -*-

NAME = "rwtocore"
require File.expand_path(File.join("..", "lib", NAME, "version"), __FILE__)

Gem::Specification.new do |spec|
  spec.name          = NAME
  spec.version       = Rwtocore::VERSION
  spec.authors       = ["Martin Munro"]
  spec.email         = ["mmunro@ltrr.arizona.edu"]
  spec.summary       = "Convert tree-ring measurements to drawings of cores"
  spec.description   = <<-END_DESCR
    Inverts the usual process of ring width measurement, taking a series of
    ring widths and generating a SVG image of a core that could have
    produced this.
  END_DESCR
  spec.license       = "MIT"
  spec.executables   << NAME
  spec.files         = Dir.glob(File.join("{lib,test}", "**", "*.rb")) +
                       %w(Gemfile LICENSE.txt README.md Rakefile rwtocore.gemspec) +
                       spec.executables.map { |x| File.join(spec.bindir, x) }
  spec.test_files    = Dir.glob(File.join("test", "**", "*_spec.rb"))
  spec.add_dependency "builder", "~> 3.2"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "nokogiri", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "redcarpet", "~> 2.0"
  spec.add_development_dependency "yard", "~> 0.9.11"
end
