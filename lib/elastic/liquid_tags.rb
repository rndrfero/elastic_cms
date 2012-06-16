# initialize -> parse -> render


require 'liquid'
# require 'net/http'
require 'open-uri' 


# insert content from node:
# {% give_me node 'this-node' %}
# {{ node.content[0] }}

module Elastic
  
  # give_me node|gallery 'this-is-the-key'
  # give_me node|gallery 1123
  # give_me file /x/in/the/system
  # give_me file /in/the/system
  # give_me html http://en.wikipedia.org/wiki/Main_Page   
  
  class GiveMeTag < Liquid::Tag    
    Syntax = /(gallery|node|html|file)\s+(#{Liquid::QuotedFragment}+)/
    
    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @what = $1
        @which = Liquid::Variable.new($2) #$2
      else
        raise Liquid::SyntaxError.new("Syntax Error in 'give_me' - Valid syntax: give_me (gallery|node) key_or_id")
      end
      
      super
    end

    def render(context)     
      # render variable
      @which = @which.render(context)
      # array case
      return [] if @which == []
      @which = @which[ rand(@which.size) ] if @which.is_a? Array
            
      if @what == 'file'
      elsif @what == 'html'
        begin
          uri = URI.parse @which
#          ret = Net::HTTP.get uri.host, uri.path           
          
#          ret = Net::HTTP.get_response(uri)
          # if ret.code == "301"
          #   ret = Net::HTTP.get_response(URI.parse(r['location']))
          # end
          ret = open uri
          return "Can not open uri: #{uri}" if not ret
          ret = ret.read
        rescue URI::InvalidURIError=>e
          return e.message
        end
      else # node, gallery
              
        itemclass = ('Elastic::'+@what.camelize).constantize           
        dropclass = "#{@what.camelize}Drop".constantize
            
        if @which.class.to_s.ends_with? 'Drop'
          Context.ctrl.add_reference @which.instance_variable_get "@#{@what}"
          context.scopes.last['the_'+@what] = @which
        else      
          # we got to find it
          item = itemclass.where(:site_id=>Context.site.id).send (@which.to_i == 0 ? :find_by_key : :find_by_id), @which
          if item
            Context.ctrl.add_reference item
            context.scopes.last['the_'+@what] = dropclass.new item
          else
            return "Cannot find #{@what} identified by '#{@which}'."
          end
        end
      end
      
      context.scopes.last['the_'+@what] = ret
      nil # render nothing
    end    
  end


  # steal http://en.wikipedia.org/wiki/Main_Page | xpath: /html/body/div[3]/div[3]/div[4]/table[2]/tbody/tr/td/table/tbody/tr[2]/td/div/p
  # class StealTag < Liquid::Tag
  #   def initialize(tag_name, markup, tokens)
  #     @markup = markup
  #     super
  #   end
  #   
  #   def render(context)
  #     uri = URI.parse @markup
  #     Net::HTTP.get uri.host, uri.path
  #   end
  # end
  
  
  
  class RawTag < Liquid::Block
    def parse(tokens)
      @nodelist ||= []
      @nodelist.clear
      
      while token = tokens.shift
        if token =~ FullToken
          if block_delimiter == $1
            end_tag
            return
          end
        end
        @nodelist << token if not token.empty?
      end
    end
  end  
  
  class MdTag < Liquid::Block
    def initialize(tag_name, markup, tokens)
      super
    end

    def render(context)
      output = super
      BlueCloth.new(output).to_html
    end
  end
  
end

Liquid::Template.register_tag 'give_me', Elastic::GiveMeTag
# Liquid::Template.register_tag 'steal', Elastic::StealTag
Liquid::Template.register_tag 'raw', Elastic::RawTag
Liquid::Template.register_tag 'md', Elastic::MdTag

