module Elastic
  module Tincan

    # structure yaml contants:
    #  - site configuration (incl. theme)
    #  - default gallery configuration
    #  - section/content_configs
    
    def tincan_dump(_prefix)
      ret = {}
      for k in tincan_map[_prefix+'_attrs']
        ret[k] = self.send(k)
      end
      for k in tincan_map[_prefix+'_assoc']
        v = self.send(k)
        if v.is_a? Array
          ret[k] = v.map{ |x| x.tincan_dump _prefix }
        else
          ret[k] = v.tincan_dump _prefix
        end
      end
      ret
    end
    
    def tincan_load=(_prefix, x, overwrite=false)
    end
    
    def tincan_map
      raise 'EXPECTED MODEL TO OVERRIDE THIS'
    end
    
  end
end
