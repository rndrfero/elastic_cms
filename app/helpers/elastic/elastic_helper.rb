module Elastic
  module ElasticHelper
    
    def exit_path
      if @action == 'show'
        show_path @node.key
      elsif @action == 'section'
        section_path @section.key
      elsif @action == 'index'
        index_path
      elsif @action == 'liquid'
        liquid_path params[:filepath]
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
      elsif @action == 'liquid'
        send "#{action}_liquid_path", content_id, params[:filepath]
      else
        raise 'unexpected'
      end
    end
        
  end
end
