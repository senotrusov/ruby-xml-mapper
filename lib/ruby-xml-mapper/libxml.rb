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
require 'xml/libxml'

module RubyXmlMapper::RubyXmlMapperClassMethods
  def libxml_parse_xml_file(file_name)
    check_file file_name

    doc = XML::Document.file(file_name)
    doc.xinclude
    doc.root
  end
  
  alias_method :parse_xml_file, :libxml_parse_xml_file
end