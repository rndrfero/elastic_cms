module Elastic
  module ApplicationHelper
    
    def menu_link_to(label, path)
      req_path = request.path.gsub(/\/\//, "/")
      options = {}
      options[:class]= "active" if req_path.starts_with? path
      raw link_to label, path, options
    end

    def menu_match(*args)
      return false if @menu_matched
      args = args.first if args.first.is_a? Array
      req_path = request.path.gsub(/\/\//, "/")
      for arg in args
          if req_path.starts_with? arg
            @menu_matched = true
            return true
          end
      end
      return false
    end
    
  end
end
