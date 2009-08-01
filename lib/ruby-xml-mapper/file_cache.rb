
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
 
class RubyXmlMapper::FileCache
  def initialize
    @items = {}
    @mutex = Mutex.new
  end
  
  def get filename, &block
    @mutex.synchronize do
      @items[filename] ||= RubyXmlMapper::FileCacheItem.new(filename)
    end
    
    @items[filename].get &block
  end
  
  def any_changes?
    !no_changes?
  end
  
  def no_changes?
    @mutex.synchronize do
      @items.all? { |filename, item| item.no_changes? }
    end
  end
  
  def clear
    @mutex.synchronize do
      @items.clear
    end
  end 
  
end
