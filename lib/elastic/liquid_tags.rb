require 'liquid'

module Elastic
  class SnippetTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
       super
       @markup = markup
    end

    def render(context)
#      Liquid::Template.parse f.read
      raise context.to_s
      @template = Liquid::Template.parse(text)
      @template.render
      "contenssssxt: #{context}"
    end    
  end
end

Liquid::Template.register_tag 'snippet', Elastic::SnippetTag

