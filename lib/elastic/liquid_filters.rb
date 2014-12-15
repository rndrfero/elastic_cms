# encoding: utf-8

require 'liquid'
require 'nokogiri'

module Elastic
  module LiquidFilters
    
    def live(x)
      x = x.to_s # ContentDrop passed instead of string
      if Elastic::Context.user and Elastic::Context.content
        Elastic::Context.ctrl.send :render_to_string, :partial=>'/elastic/public/live_content',
          :locals=>{:content=>Elastic::Context.content, :rendered=>x.to_s }
      else
        x
      end
    end

    def random(array)
      return array if Elastic::Context.ctrl.am_i_editing_this_shit?
      if array.is_a? Array
        array[ rand(array.size) ]
      else
        'undefined'
      end
    end
    
    def gsub(x,regexp_str,str='')
      if x.is_a? Array
        x.map { |xx| xx.gsub Regexp.new(regexp_str), str }
      else
        x.gsub Regexp.new(regexp_str), str
      end
    end
    
    def md(x)
      x = x.to_s # ContentDrop case
      Elastic::Context.ctrl.am_i_editing_this_shit? ? x : BlueCloth.new(x).to_html
    end

    def splitnl(input)
      input = input.to_s
      return input if Elastic::Context.ctrl.am_i_editing_this_shit?
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
    
    def strftime(x,format)
      x.strftime(format)
    end

    def math_mod(number, modulus)
      (number.to_i % modulus.to_i).to_s
    end
    
  end

  Liquid::Template.register_filter LiquidFilters
end


