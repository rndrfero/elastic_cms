module Elastic
  class Devise::SessionsController < DeviseController
    layout 'elastic/sessions'
    
    prepend_before_filter :require_no_authentication, :only => [ :new, :create ]
    prepend_before_filter :allow_params_authentication!, :only => :create
    
    before_filter do
      Context.site = Site.find_by_host request.host
      if not Context.site
        render :inline=>"404: No site for host '#{request.host}' found.", :status=>404
        return false
      end
    end

    # GET /resource/sign_in
    def new
#      raise 'pico'
      
      resource = build_resource(nil, :unsafe => true)
      clean_up_passwords(resource)
      respond_with(resource, serialize_options(resource))
    end

    # POST /resource/sign_in
    def create
#      raise 'pico'
      
      resource = warden.authenticate!(auth_options)
            
      if resource.site_id == Context.site.id or Context.site.master_id == resource.id      
        set_flash_message(:notice, :signed_in) if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_in_path_for(resource)
      else
#        set_flash_message(:alert, :site) if is_navigational_format?
        flash.now[:alert] = I18n.t 'devise.failure.invalid'
        warden.logout resource_name
        render :action=>'new'
      end
      
    end

    # DELETE /resource/sign_out
    def destroy
#      raise 'pico'
      warden.logout resource_name
      redirect_to '/'
      
      # redirect_path = after_sign_out_path_for(resource_name)
      # signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
      # set_flash_message :notice, :signed_out if signed_out
      # 
      # # We actually need to hardcode this as Rails default responder doesn't
      # # support returning empty response on GET request
      # respond_to do |format|
      #   format.any(*navigational_formats) { redirect_to redirect_path }
      #   format.all do
      #     head :no_content
      #   end
      # end
    end

    protected

    def serialize_options(resource)
      methods = resource_class.authentication_keys.dup
      methods = methods.keys if methods.is_a?(Hash)
      methods << :password if resource.respond_to?(:password)
      { :methods => methods, :only => [:password] }
    end

    def auth_options
      { :scope => resource_name, :recall => "#{controller_path}#new" }
    end
  end
end
