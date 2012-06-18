# encoding: utf-8

require 'liquid'
require 'nokogiri'

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
      return x if Elastic::Context.ctrl.instance_variable_get('@edit')
      BlueCloth.new(x).to_html
    end

    def splitnl(input)
      input.to_s.split("\n")
    end
    
    def xpath(x, xpath)
#      raise x.inspect
      doc = Nokogiri::HTML(x)
      ret = doc.xpath(xpath)
      ret.empty? ? nil : ret.first.to_s #.content      
    end
    
    def css(x, css)    
      # doc = Nokogiri::HTML(x)
      # doc.xpath(css).first.content
    end
    
  end

  Liquid::Template.register_filter LiquidFilters
end


