require 'liquid'

class Array
  def random
    empty? ? nil : self[rand(size)]
  end
end

module Liquid
  
  
  class Drop
    def type
      self.class.to_s.gsub(/Drop/,'').underscore
    end
  end
  
  class Block < Tag
    def render_all(list, context)
      list.collect do |token|
        begin
          x = token.respond_to?(:render) ? token.render(context) : token
          x.force_encoding('utf-8') if x.respond_to?(:force_encoding)
          x
        rescue ::StandardError => e
          context.handle_error(e)
        end
      end.join
    end
  end
  
  class Context
    def handle_error(e)
      errors.push(e)
#      raise if Rails.env=='development'

      case e
      when SyntaxError
        "Liquid syntax error: #{e.message}"
      else
        Rails.logger.error e.message
        Rails.logger.error e.backtrace.join("\n")
        "Liquid error: #{e.message}"
      end
    end
    
    
    def variable(markup)
      parts = markup.scan(VariableParser)
      square_bracketed = /^\[(.*)\]$/

      first_part = parts.shift

      if first_part =~ square_bracketed
        first_part = resolve($1)
      end

      if object = find_variable(first_part)

        parts.each do |part|
          part = resolve($1) if part_resolved = (part =~ square_bracketed)

          # If object is a hash- or array-like object we look for the
          # presence of the key and if its available we return it
          if object.respond_to?(:[]) and
            ((object.respond_to?(:has_key?) and object.has_key?(part)) or
             (object.respond_to?(:fetch) and part.is_a?(Integer)))

            # if its a proc we will replace the entry with the proc
            res = lookup_and_evaluate(object, part)
            object = res.to_liquid
          
            # Elastic CMS special case
          elsif !part_resolved and object.is_a? Array and part == 'random'
            return nil if object.empty?
            object = object[ rand(object.size) ]
            
            # Elastic CMS special case
          elsif !part_resolved and object.is_a? Array and part == 'starry'
            return nil if object.empty?
            object = object.select{ |x| x.respond_to?(:is_star?) and x.is_star? }

            # Some special cases. If the part wasn't in square brackets and
            # no key with the same name was found we interpret following calls
            # as commands and call them on the current object
          elsif !part_resolved and object.respond_to?(part) and ['size', 'first', 'last'].include?(part)
#          elsif !part_resolved and object.respond_to?(part) and [].include?(part)

            object = object.send(part.intern).to_liquid

            # No key was present with the desired value and it wasn't one of the directly supported
            # keywords either. The only thing we got left is to return nil
          else
            return nil
          end

          # If we are dealing with a drop here we have to
          object.context = self if object.respond_to?(:context=)
        end
      end
      
      object
    end
    
  end
end