module Elastic
  module ApplicationHelper
    
    def img_factor(w,h)
      c = 300
      w, h = w.to_f, h.to_f
      fw = (w/c).to_i
      fh = (h/c).to_i
      m = fw > fh ? fw : fh
      return ELASTIC_CONFIG['gallery']['fallback_tn_w'],ELASTIC_CONFIG['gallery']['fallback_tn_h'] if m==0
      return (w/m).to_i, (h/m).to_i
    end

    def ic(x, color=nil)
      raw "<img class=\"icoimg\" src=\"/assets/iconic/#{color}/#{x}.png\" />"
    end
        
    # def wdbg(x)
    #   false ? raw("<div class=\"wakeDebug\">#{x}</div>") : ''
    # end
    # 
    # def wnote(x)
    #   true ? raw("<div class=\"wakeNote\">NOTE: #{x}</div>") : ''
    # end
    # 
    # def werror(x)
    #   true ? raw("<div class=\"wakeError\">ERROR: #{x}</div>") : ''
    # end
    # 
    # def menu_link_to(label, path)
    #   req_path = request.path.gsub(/\/\//, "/")
    #   options = {}
    #   options[:class]= "active" if req_path.starts_with? path
    #   raw link_to label, path, options
    # end
    # 
    # def menu_match(*args)
    #   return false if @menu_matched
    #   args = args.first if args.first.is_a? Array
    #   req_path = request.path.gsub(/\/\//, "/")
    #   for arg in args
    #       if req_path.starts_with? arg
    #         @menu_matched = true
    #         return true
    #       end
    #   end
    #   return false
    # end
    
  end
end
