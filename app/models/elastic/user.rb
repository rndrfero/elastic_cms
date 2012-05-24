module Elastic
  class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable,
    # :lockable, :timeoutable and :omniauthable
    # devise :database_authenticatable, :registerable,
    #        :recoverable, :rememberable, :trackable, :validatable
  
    devise :database_authenticatable, :rememberable, :trackable, :validatable

    # Setup accessible (or protected) attributes for your model
    attr_accessible :email, :password, :password_confirmation, :remember_me
    # attr_accessible :title, :body
      
    # elastic
    belongs_to :site
    has_many :sites, :foreign_key=>'master_id'
  
    attr_accessible :name, :site_id
    
    def editor?(the_site=Context.site)
      self.site_id == the_site.id or master_of? the_site.id
    end
    
    def master?(the_site=Context.site)
      self.site_id == the_site.master_id
    end
        
  end
end