require_relative 'lib/composite_task/version'

Gem::Specification.new do |s|
  s.name             = 'composite_task'
  s.version          = CompositeTask::VERSION
  s.summary          = 'Gang of Four Composite Design Pattern Implementation (with goodies)'
  s.description      = "This Gem implement GoF's Composite pattern for Ruby. It comes with some helper methods, and can generate progress output (even colored for terminal)."
  s.email            = 'fabio.ornellas@gmail.com'
  s.homepage         = 'https://github.com/fornellas/composite_task'
  s.authors          = ['Fabio Pugliese Ornellas']
  s.files            = Dir.glob('lib/**/*').keep_if{|p| not File.directory? p}
  s.extra_rdoc_files = ['README.md']
  s.rdoc_options     = %w{--main README.md lib/ README.md}
  s.add_development_dependency 'rake', '~>10.4'
  s.add_development_dependency 'gem_polisher', '~>0.4'
  s.add_development_dependency 'rspec', '~>3.4'
  s.add_development_dependency 'simplecov', '~>0.11', '>=0.11.2'
end
