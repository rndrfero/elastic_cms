require_dependency "wake.rb"

module Elastic
  
  class Admin::SitesController < ApplicationController
    
    include Wake
    helper :wake
    
    def _model; Site; end
    def _ident; 'site'; end
        
  end
  
end
