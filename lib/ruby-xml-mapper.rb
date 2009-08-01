
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


# In fact, this is prototype to define requirements.
#   TODO: refactoring
#   TODO: Extract mapping to separate object
#   TODO: More clear caching
#   TODO: File loading with filesystem restrictions and current directory (based on parent xml directory)
#   TODO: Use more libxml API 

require 'libxml'

module RubyXmlMapper
   class CircularReference < StandardError; end
end

require 'ruby-xml-mapper/file_cache_item'
require 'ruby-xml-mapper/file_cache'

module RubyXmlMapper
  mattr_accessor :file_cache
  self.file_cache = RubyXmlMapper::FileCache.new
  
  def self.included model
    model.extend RubyXmlMapper::RubyXmlMapperClassMethods
    
    model.class_inheritable_accessor :xml_name
    model.class_inheritable_accessor :source_dir_path
    
    model.class_inheritable_accessor :xml_self_mapping
    model.class_inheritable_accessor :xml_content_mapping
    model.class_inheritable_hash :xml_attr_mappings
    model.class_inheritable_hash :xml_child_mappings
    
    model.xml_attr_mappings = {}
    model.xml_child_mappings = {}
  end

  def initialize_from_xml node
    initialize_from_xml_attr_mapping(node) if xml_attr_mappings.length
    initialize_from_xml_child_mapping(node) if xml_child_mappings.length
    initialize_from_xml_self_mapping(node) if xml_self_mapping
    initialize_from_xml_content_mapping(node) if xml_content_mapping
  end
  
  private
  
  def initialize_from_xml_attr_mapping node
    node.each_attr do |attr|
      if (mapping = xml_attr_mappings[attr.name])
        self.__send__(mapping[:writer_method], mapping[:type].new_from_xml_attr(attr))
      end
    end

    # Applying default values
    xml_attr_mappings.each do |key, mapping|
      if mapping[:default] && self.__send__(mapping[:reader_method]).nil?
        self.__send__(mapping[:writer_method], mapping[:default])
      end
    end
  end


  def initialize_from_xml_child_mapping node
    node.each_element do |child|
      if (mapping = xml_child_mappings[child.name])
        map_xml_node child, mapping
      end
    end
    
    # Applying default values
    xml_child_mappings.each do |key, mapping|
      if mapping[:types] && !self.__send__(mapping[:reader_method]) # TODO: handle as default (below)
        self.__send__(mapping[:writer_method], Array.new)
      end

      if mapping[:default] && self.__send__(mapping[:reader_method]).nil?
        self.__send__(mapping[:writer_method], mapping[:default])
      end
    end
  end
  
  def map_xml_node node, mapping
    if (types = mapping[:types]) || mapping[:multiple]
      unless (array = self.__send__(mapping[:reader_method]))
        array = self.__send__(mapping[:writer_method], Array.new)
      end

      if mapping[:multiple]
        array.push(mapping[:type].new_from_xml_node(node))
      else
        node.each_element do |child|
          if(type = types[child.name])
            array.push(type.new_from_xml_node(child))
          end
        end
      end
    else
      self.__send__(mapping[:writer_method], mapping[:type].new_from_xml_node(node))
    end
  end


  def initialize_from_xml_self_mapping node
    if xml_self_mapping[:type].kind_of?(Array)
      types = xml_self_mapping[:types]

      node.each_element do |child|
        if(type = types[child.name])
          self.push(type.new_from_xml_node(child))
        end
      end
    elsif xml_self_mapping[:type] == :self
      self.initialize_from_xml_node node
    end
  end
  
  def initialize_from_xml_content_mapping node
    self.__send__(xml_content_mapping[:writer_method], xml_content_mapping[:type].new_from_xml_node(node))
  end
  
  
  
  module RubyXmlMapperClassMethods
    def parse_xml_file(file_name)
      check_file file_name

      # NOTE: Don't know how to use XML::Document.file correctly.
      # As in libxml-ruby-1.1.3 it does not close file descriptor, so you end up with "Error: Too many open files."
      
      doc = LibXML::XML::Document.string(File.read(file_name))

      # NOTE: If document does not created from file, it leads to "Segmentation fault"
      # doc.xinclude

      doc.root
    end


    def check_file file_name
      unless File.file?(file_name)
        raise "Unable to find file #{file_name.inspect}"
      end

      unless File.readable?(file_name)
        raise "File is not readable #{file_name.inspect}"
      end
    end
    
    def new_from_xml_file file_name
      RubyXmlMapper.file_cache.get(file_name) do
        new_from_xml_node(parse_xml_file(file_name))
      end
    end

    def new_from_xml_node node
      if node.attributes["source"]
        unless source_dir_path
          raise "source_dir_path not defined in #{self.class.inspect}"
        end
        new_from_xml_file(File.expand_path_restricted(node.attributes["source"], source_dir_path))
      else        
        allocated = allocate
        allocated.initialize_from_xml node
        allocated.after_initialize if allocated.respond_to?(:after_initialize) 
        allocated
      end
    end

    def xml args
      register_method = args.keys.detect {|key| self.respond_to?("register_#{key}_mapping", true)} || "self"
      
      self.__send__("register_#{register_method}_mapping", args)
    end
    
    
    private
    
    def register_attr_mapping args
      args[:reader_method] = args[:attr]
      args[:writer_method] = "#{args[:attr]}="
      args[:tag_name] ||= args[:attr].to_s
      
      attr_accessor args[:reader_method].to_sym
      
      xml_attr_mappings[args[:tag_name]] = args
    end
    
    
    def register_child_mapping args
      args[:tag_name] ||= args[:child].to_s

      if args[:multiple]
        args[:reader_method] = args[:multiple]
        args[:writer_method] = "#{args[:multiple]}="
      else
        args[:reader_method] = args[:child]
        args[:writer_method] = "#{args[:child]}="
      end

      register_type_array(args) if args[:type].kind_of?(Array)
      
      attr_accessor args[:reader_method].to_sym
      xml_child_mappings[args[:tag_name]] = args
    end
    
    
    def register_self_mapping args
      if args[:type].kind_of?(Array)
        register_type_array(args)
      elsif args[:type] == :self && self < RubyXmlMapper::Hash
         
      else
        raise(":type must be kind_of Array or :self with the following supported types: RubyXmlMapper::Hash )")
      end

      self.xml_self_mapping = args
    end
    

    def register_content_mapping args
      args[:reader_method] = args[:content]
      args[:writer_method] = "#{args[:content]}="
      
      attr_accessor args[:reader_method].to_sym
      
      self.xml_content_mapping = args
    end

    def register_type_array args
      args[:types] = {}
      args[:type].each do |klass|
        args[:types][klass.respond_to?(:xml_name) && klass.xml_name || klass.to_s.split('::').last.underscore] = klass
      end
    end
  end
end

require 'ruby-xml-mapper/basic_containers'

