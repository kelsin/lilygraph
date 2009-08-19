# Gem spec for lilygraph
require 'rake'

Gem::Specification.new do |s|
  s.name = %q{lilygraph}
  s.version = "0.1"

  s.authors = ["Christopher Giroir"]
  s.email = %q{kelsin@valefor.com}
  s.homepage = %q{http://github.com/Kelsin/lilygraph}
  s.date = %q{2009-08-19}
  s.summary = %q{Lilygraph is a Ruby library for creating svg charts and graphs based on XmlBuilder.}
  s.description = %q{Lilygraph is a Ruby library for creating svg charts and graphs based on XmlBuilder.}

  s.files = FileList["{bin,lib}/**/*"].to_a
  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.require_paths = ["lib"]
  s.has_rdoc = true
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.extra_rdoc_files = ["README", "LICENSE"]
  
  s.add_dependency("builder", ">= 2.1.2")
  s.add_dependency("color-tools", ">= 1.3.0")
  s.add_development_dependency("rake", ">= 0.8.7")

  s.platform = Gem::Platform::RUBY
  s.rubygems_version = %q{1.3.0}
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
end
