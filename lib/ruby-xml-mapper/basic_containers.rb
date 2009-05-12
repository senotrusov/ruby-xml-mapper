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
 

# TODO: Double check .strip - is it needed actually

class String
  def self.new_from_xml_attr attr
    new(attr.value.strip.gsub(/\s*[\r\n]\s*/, "\n"))
  end

  def self.new_from_xml_node node
    new(node.content.strip.gsub(/\s*[\r\n]\s*/, "\n"))
  end
end

class Symbol
  def self.new_from_xml_attr attr
    String.new_from_xml_attr(attr).to_sym
  end

  def self.new_from_xml_node node
    String.new_from_xml_node(node).to_sym
  end
end

class Class
  def self.new_from_xml_attr attr
    Object.full_const_get(String.new_from_xml_attr(attr))
  end

  def self.new_from_xml_node node
    Object.full_const_get(String.new_from_xml_node(node))
  end
end

class Integer
  def self.new_from_xml_attr attr
    attr.value.to_i
  end

  def self.new_from_xml_node node
    node.content.to_i
  end
end

class RubyXmlMapper::Boolean
  def self.new_from_xml_attr attr
    (attr.value =~ /\A\s*true\s*\z/i) ? true : false
  end

  def self.new_from_xml_node node
    (node.content =~ /\A\s*true\s*\z/i) ? true : false
  end
end

class RubyXmlMapper::HashOfStringAndNumeric < Hash
  def self.new_from_xml_node node
    created = new
    created.initialize_from_xml_node node
    created
  end

  def initialize_from_xml_node node
    node.each_element do |child|
      self[child.name.to_sym] = autocast_value(child.content)
    end
    node.each_attr do |attr|
      self[attr.name.to_sym] = autocast_value(attr.value)
    end
  end

  def autocast_value value
      if value =~ /\A\s*-*\d+\.\d+\s*\z/
        value.to_f

      elsif value =~ /\A\s*-*\d+\s*\z/
        value.to_i

      elsif matchdata = value.match(/\A\s*(-*\d+)\s*\.\.\s*(-*\d+)\s*\z/)
        Range.new(matchdata[1].to_i, matchdata[2].to_i)

      elsif value =~ /\A\s*true\s*\z/i
        true

      elsif value =~ /\A\s*false\s*\z/i
        false

      else
        value.strip.gsub(/\s*[\r\n]\s*/, "\n").gsub(/\n\s*\n/, "\n")
        
      end
  end
end

require 'time'

class Time
  def self.new_from_xml_attr attr
    parse(attr.value)
  end

  def self.new_from_xml_node node
    parse(node.content)
  end
end
