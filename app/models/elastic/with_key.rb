require 'iconv'

module Elastic
  module WithKey
    
    def self.included(base)
      base.send :validates_format_of, :key, :with=>/^[a-zA-Z0-9\-_]*$/
    end
    
    def generate_key(x=send(:title))
      return if key.blank?
      x = x.strip
      ret = Iconv.new("ascii//TRANSLIT","utf-8").iconv(x).downcase.gsub(/ /, '-').gsub(/[^\-\_a-z0-9]*/,'') 
      ret.gsub!(/--/,'-') # double dash
      self.key = ret
    end  
    
  end
end
