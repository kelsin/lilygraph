# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{lilygraph}
  s.version = "0.5.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christopher Giroir"]
  s.date = %q{2009-09-15}
  s.description = %q{Lilygraph is a Ruby library for creating svg charts and graphs based on XmlBuilder.}
  s.email = %q{kelsin@valefor.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README",
     "Rakefile",
     "VERSION",
     "doc/classes/Lilygraph.html",
     "doc/classes/Lilygraph.src/M000001.html",
     "doc/classes/Lilygraph.src/M000002.html",
     "doc/classes/Lilygraph.src/M000003.html",
     "doc/created.rid",
     "doc/files/lib/lilygraph_rb.html",
     "doc/fr_class_index.html",
     "doc/fr_file_index.html",
     "doc/fr_method_index.html",
     "doc/index.html",
     "doc/rdoc-style.css",
     "lib/lilygraph.rb",
     "lilygraph.gemspec"
  ]
  s.homepage = %q{http://github.com/Kelsin/lilygraph}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Lilygraph is a Ruby library for creating svg charts and graphs based on XmlBuilder.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<color-tools>, [">= 1.3.0"])
    else
      s.add_dependency(%q<color-tools>, [">= 1.3.0"])
    end
  else
    s.add_dependency(%q<color-tools>, [">= 1.3.0"])
  end
end
