module Elastic
  class Identity < OmniAuth::Identity::Models::ActiveRecord #ActiveRecord::Base
    attr_accessible :email, :password, :password_confirmation, :uid, :provider
    
    # OmniAuth.on_failure do |env|
    #   [200, {}, [env['omniauth.error'].inspect]]
    # end    # attr_accessible :title, :body
    
    belongs_to :user

    def self.find_with_omniauth(auth)
      find_by_provider_and_uid(auth['provider'], auth['uid'])
    end

    def self.create_with_omniauth(auth)
      Identity.create(uid: auth['uid'], provider: auth['provider'])
    end
  end
end
