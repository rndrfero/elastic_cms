module Elastic
  class Admin::InfoController < ApplicationController
    
    helper :wake
    
    def index
      flash.now[:notice] = 'Internal system configuration, vole'
      render :action=>'info'
    end

  end
end