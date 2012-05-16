module Elastic
  class Efx
    LIST = {
      :sepia => {
        :description => "Generates sepia tone.",
        :command => Proc.new{ |x| "-sepia-tone #{x[:intensity]}%" }, 
        :parameters => { :intensity => :percentage }
      },
      :desaturate => {
        :description => "Convert to grayscale",
        :command => '-quantize Gray -colors 256',
        :parameters => {}
      },
      :brightness => {
        :description => "Brightness & saturation.",
        :command => Proc.new{ |x| "-modulate #{x[:brightness]}%,#{x[:saturation]}%" }, 
        :parameters => { :brightness => :percentage, :saturation => :percentage }
      },
      :color_adjust => {
        :description => "Brightness & Saturation -> Colorize.",
        :command => Proc.new{ |x| "-modulate #{x[:brightness]}%,#{x[:saturation]}% -fill '##{x[:color]}' -colorize #{x[:colorize]}% " }, 
        :parameters => { :brightness => :percentage, :saturation => :percentage, 
           :color => :color, :colorize=> :percentage }
      },
      :reduce_colors => {
        :description => "Levels -> Reduce to N colors.",
        :command => Proc.new{ |x| "-level #{x[:black_point]}%,#{x[:white_point]}%  +dither -colors #{x[:colors]} " }, 
        :parameters => { :black_point => :percentage, :white_point => :percentage, :colors => :number }
      },
            
    }    

    def initialize(x, values)
      @efx = LIST[x.to_sym]
      @values = sanitize_values values
#      raise @values.inspect
    end

    def description
      @efx[:description]
    end
    
    def command
      @efx[:command]
    end
    
    def parameters
      @efx[:parameters]
    end
    
    def valid?
      for k,v in parameters
        return false if @values[k].blank?
      end
      return true
    end
        
    def process!(src, dest)
      raise 'INVALID' unless valid?
      cmd = command if command.is_a? String
      cmd = command.call @values if command.is_a? Proc
      
      Elastic.logger_info "EFX: #{cmd}"     
      %x{convert "#{src}" #{cmd} "#{dest}"} 
    end

    private
    def sanitize_values(values)
      safe = {}
      for k,v in values||{}
        safe.merge!({ k.to_sym => v.to_i }) if parameters[k.to_sym] == :percentage        
        safe.merge!({ k.to_sym => v.to_i }) if parameters[k.to_sym] == :number        
        safe.merge!({ k.to_sym => v.upcase.gsub(/[^0-9A-F]/,'') }) if parameters[k.to_sym] == :color        
      end
      safe
    end
    
  end
end