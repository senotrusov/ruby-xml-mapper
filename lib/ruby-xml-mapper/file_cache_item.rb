
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
 

class RubyXmlMapper::FileCacheItem
  def initialize filename
    @filename = filename
    @mutex = Mutex.new
  end
  
  def get
    raise(RubyXmlMapper::CircularReference, "in `#{@filename}'") if @mutex.locked?
    
    @mutex.synchronize do
      mtime = File.mtime(@filename)
      
      if @data && @mtime == mtime
        return @data
        
      elsif block_given?
        @mtime = mtime
        return (@data = yield)
        
      else
        return @data
      end
    end
  end
  
  def no_changes?
    @mutex.synchronize do
      File.mtime(@filename) == @mtime
    end
  end
  
end
