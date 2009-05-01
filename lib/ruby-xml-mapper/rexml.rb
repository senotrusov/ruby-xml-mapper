# 
#  Copyright 2007-2008 Stanislav Senotrusov <senotrusov@gmail.com>
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
 
require 'ruby-xml-mapper'
require 'rexml/document'

class REXML::Element
  def each_attr(&block)
    self.attributes.each_attribute(&block)
  end

  def content
    children.collect do |child|
      child.content
    end.join
  end
end

class REXML::Text
  alias_method :content, :value
end

module RubyXmlMapper::RubyXmlMapperClassMethods
  def rexml_parse_xml_file(file_name)
    check_file file_name

    REXML::Document.new(File.read(file_name)).root
  end

  alias_method :parse_xml_file, :rexml_parse_xml_file
end