# 
#  Copyright 2006-2008 Stanislav Senotrusov <senotrusov@gmail.com>
# 
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.


require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'

spec = Gem::Specification.new do |s|
  s.name          = "ruby_xml_mapper"
  s.version       = "1.0.0"
  
  s.platform      = Gem::Platform::RUBY
  s.has_rdoc      = true
  s.extra_rdoc_files  = %w(README LICENSE)
  
  s.summary       = "Ruby XML Mapper"
  s.description   = "Mapping XML to/from Ruby with REXML and LibXML bindings"
  s.author        = "Stanislav Senotrusov"
  s.email         = "senotrusov@gmail.com"
  s.homepage      = "http://rubymq.rubyforge.org/"
  s.rubyforge_project = 'rubymq'
  
  s.require_path  = 'lib'
  s.files         = %w(README LICENSE Rakefile) + Dir.glob("{lib,spec,test}/**/*")
  
  s.add_dependency 'rubymq_facets', '3.0.0'
  s.add_dependency 'libxml-ruby', '>=1.1.3'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

