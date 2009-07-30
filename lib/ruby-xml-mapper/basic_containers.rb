
#  Copyright 2008-2009 Stanislav Senotrusov <senotrusov@gmail.com>
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
    String.new_from_xml_attr(attr).constantize
  end

  def self.new_from_xml_node node
    String.new_from_xml_node(node).constantize
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

class RubyXmlMapper::Hash < Hash

  def initialize_from_xml_node node
    node.each_element do |child|
      next if xml_child_mappings.has_key?(child.name)
      
      self[child.name.to_sym] = if child.attributes["type"] && respond_to?(cast_method = "cast_to_#{child.attributes["type"]}")
          __send__(cast_method, child.content)
        else
          autocast_value(child.content)
        end
    end
    
    node.each_attr do |attr|
      next if xml_attr_mappings.has_key?(attr.name)
      
      self[attr.name.to_sym] = autocast_value(attr.value)
    end
  end

  # we're eating copypasta!
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
  
  def cast_to_float value
    value.to_f
  end
  
  def cast_to_integer value
    value.to_i
  end
  
  def cast_to_range value
    matchdata = value.match(/\A\s*(-*\d+)\s*\.\.\s*(-*\d+)\s*\z/)
    Range.new(matchdata[1].to_i, matchdata[2].to_i)
  end
  
  def cast_to_boolean value
    if value =~ /\A\s*true\s*\z/i
        true
    elsif value =~ /\A\s*false\s*\z/i
      false
    else
      nil
    end
  end
  
  def cast_to_string value
    value.strip.gsub(/\s*[\r\n]\s*/, "\n").gsub(/\n\s*\n/, "\n")
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
