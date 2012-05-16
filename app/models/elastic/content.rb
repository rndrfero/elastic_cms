module Elastic  
  class Content < ActiveRecord::Base

    has_paper_trail    
    
    attr_accessible :content_config, :node, :content_config_id, :node_id, :text, :locale
  
    belongs_to :node
    belongs_to :content_config
  
  #  validates_presence_of :node

    # -- wake --
  
    def self.wake_includes
      :content_config
    end
  end
end