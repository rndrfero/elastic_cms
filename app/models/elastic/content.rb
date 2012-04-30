module Elastic  
  class Content < ActiveRecord::Base
  
    belongs_to :node
    belongs_to :content_config
  
  #  validates_presence_of :node

    # -- wake --
  
    def self.wake_includes
      :content_config
    end
  end
end