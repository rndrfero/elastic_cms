require 'liquid'

module Elastic
  class GiveMeTag < Liquid::Tag    
    Syntax = /(gallery|node)\s+(#{Liquid::QuotedFragment}+)/
    
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
      itemclass = ('Elastic::'+@what.camelize).constantize           
      dropclass = "#{@what.camelize}Drop".constantize
      
      @which = @which.render(context)      
      
      return nil if @which.class.to_s.ends_with? 'Drop'
      
      item = itemclass.where(:site_id=>Context.site.id).send (@which.to_i == 0 ? :find_by_key : :find_by_id), @which
      
      if item
        Context.ctrl.add_reference item
        context.scopes.last['the_'+@what] = dropclass.new item
        nil
      else
        "Cannot find #{@what} identified by '#{@which}'."
      end
    end    
  end
  
  
  
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
Liquid::Template.register_tag 'raw', Elastic::RawTag
Liquid::Template.register_tag 'md', Elastic::MdTag

