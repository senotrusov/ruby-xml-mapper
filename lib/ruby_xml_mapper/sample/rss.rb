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

=begin
$KCODE ="UTF8"
require 'rubygems'
require 'ruby_xml_mapper/libxml'
require 'ruby_xml_mapper/sample/rss'

rss = RSS::RSS.new_from_xml_file('http://www.reddit.com/r/programming/.rss')
rss.channel.items.each {|item| puts item.title}; nil
=end

module RSS
  class Item
    include RubyXmlMapper
    xml :child => :title, :type => String
    xml :child => :link, :type => String
    xml :child => :description, :type => String
    xml :child => :category, :type => String
    xml :child => :guid, :type => String
  end

  class Channel
    include RubyXmlMapper
    xml :child => :title, :type => String
    xml :child => :link, :type => String
    xml :child => :description, :type => String
    xml :child => :ttl, :type => Integer

    xml :child => :item, :multiple => :items, :type => RSS::Item
  end

  class RSS
    include RubyXmlMapper
    xml :child => :channel, :type => ::RSS::Channel
  end
end
