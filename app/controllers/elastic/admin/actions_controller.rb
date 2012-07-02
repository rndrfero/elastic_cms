module Elastic
  class Admin::ActionsController < ApplicationController
    
    helper :wake
    
    def index
      flash.now[:notice] = 'Internal system actions, vole'
      render :action=>'actions'
    end

    def integrity
      flash[:hilite] = 'SYSTEM.integrity!'
      Site.integrity!
      redirect_to :back
    end

  end
end