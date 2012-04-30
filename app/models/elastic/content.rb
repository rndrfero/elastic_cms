module Elastic  
  class Content < ActiveRecord::Base
    
    attr_accessible :content_config, :node, :content_config_id, :node_id, :text
  
    belongs_to :node
    belongs_to :content_config
  
  #  validates_presence_of :node

    # -- wake --
  
    def self.wake_includes
      :content_config
    end
  end
end