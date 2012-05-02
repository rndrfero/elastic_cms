module Elastic
  class User < ActiveRecord::Base
    # attr_accessible :title, :body
    
    has_many :idenities    


    def self.create_with_omniauth(info)
      create(name: info['name'])
    end
  end
end
