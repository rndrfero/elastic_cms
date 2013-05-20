module Elastic
  module WithToggles
    
    def with_toggles(*toggles)
      for x in toggles
        module_eval <<-eos
          def toggle_#{x}!
            update_attribute :is_#{x}, (is_#{x} ? false : true)
          end
        eos
      end
    end
    
  end
end

  