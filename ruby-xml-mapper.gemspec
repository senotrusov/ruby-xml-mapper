# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{senotrusov-ruby-xml-mapper}
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Stanislav Senotrusov"]
  s.date = %q{2009-07-23}
  s.email = %q{senotrusov@gmail.com}
  s.extra_rdoc_files = ["README", "LICENSE"]
  s.files = ["README", "LICENSE", "lib/ruby-xml-mapper", "lib/ruby-xml-mapper/basic_containers.rb", "lib/ruby-xml-mapper.rb", "test/rss.rb"]
  s.homepage = %q{http://github.com/senotrusov}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Mapping XML to Ruby in handy declarative manner using LibXML}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<libxml-ruby>, [">= 1.1.3"])
    else
      s.add_dependency(%q<libxml-ruby>, [">= 1.1.3"])
    end
  else
    s.add_dependency(%q<libxml-ruby>, [">= 1.1.3"])
  end
end
