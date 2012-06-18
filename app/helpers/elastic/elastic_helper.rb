module Elastic
  module ElasticHelper
    
    def exit_path
      if @action == 'show'
        show_path @node.key
      elsif @action == 'section'
        section_path @section.key
      elsif @action == 'index'
        index_path
      else
        raise 'unexpected'
      end
    end
    
    def live_path(action, content_id)
      if @action == 'show'
        send "#{action}_show_path", @node.key, content_id
      elsif @action == 'section'
        send "#{action}_section_path", @section.key, content_id
      elsif @action == 'index'
        send "#{action}_index_path", content_id
      else
        raise 'unexpected'
      end
    end
        
  end
end
