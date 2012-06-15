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
      return x if Elastic::Context.ctrl.params[:action]=='edit'
      BlueCloth.new(x).to_html
    end

    def splitnl(input)
      input.to_s.split("\n")
    end
    
  end

  Liquid::Template.register_filter LiquidFilters
end


