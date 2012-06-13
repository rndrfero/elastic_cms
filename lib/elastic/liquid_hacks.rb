require 'liquid'

module Liquid
  class Context
    def handle_error(e)
      errors.push(e)
      raise if Rails.env=='development'

      case e
      when SyntaxError
        "Liquid syntax error: #{e.message}"
      else
        "Liquid error: #{e.message}"
      end
    end
  end
end