require 'liquid'

module Elastic
  module LiquidFilters

    def random(x)
      if x.is_a? Array
        x[ rand(x.size) ]
      else
        'undefined'
      end
    end
    
    def gsub(x,regexp_str,str='')
      x.gsub Regexp.new(regexp_str), str
    end
    
    def md(x)
      BlueCloth.new(x).to_html
    end
    
  end

  Liquid::Template.register_filter LiquidFilters
end


