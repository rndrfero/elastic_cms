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
          ret[k] = v.reject{ |x| x.blank? }.map{ |x| x.tincan_dump _prefix }
        elsif not v.nil?
          ret[k] = v.tincan_dump _prefix 
        end
      end
      ret
    end
    
    def tincan_load(_prefix, data, overwrite=false)
      raise 'UNEXPECTED DATA' if data.nil? 
#      raise "#{data}" if self.class.to_s =~ /Gallery/
      for k in tincan_map[_prefix+'_attrs']
        self.send k+'=', data[k] # if self.send(k).blank? or overwrite
        self.site_id = Context.site.id if self.respond_to? 'site_id=' # resync
      end
      for k in tincan_map[_prefix+'_assoc']
        v = data[k]
        if v.is_a? Array
#          self.send k+'=', []
          v.map do |x| 
            # if assoc with the key exists, update attrs only
            # create otherwise
            item = self.send(k).where(:key=>x['key']).first if not x['key'].blank?
#             self.class.send(:column_names).include?('key') and
            item ||= self.send(k).build
            item.tincan_load _prefix, x
            
            #self.send(k).build.tincan_load _prefix, x
          end
        else
         if not v['key'].blank? and send(k) and send(k).key == v['key'] 
           self.send(k).tincan_load _prefix, v
          else
#           self.send k+'=', nil # TODO: TU BY NEMAL BYT DESTROY?
           self.send(k).destroy if self.send(k)
           self.send('build_'+k).tincan_load _prefix, v
          end if v
        end
      end
      self.save! 
      self
    end
    
    def tincan_map
      raise 'EXPECTED MODEL TO OVERRIDE THIS'
    end
    
  end
end
