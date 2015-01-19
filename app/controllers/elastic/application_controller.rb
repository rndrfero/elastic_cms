require_dependency "elastic/string"
require_dependency "elastic/context"
require_dependency "wake.rb"
require_dependency "elastic/liquid_hacks"
require_dependency "elastic/liquid_tags"
require_dependency "elastic/liquid_filters"
    
  
module Elastic
  class ApplicationController < ActionController::Base
    
    layout 'elastic/backend'

    before_filter :authenticate_user! 

    before_filter :prepare_context_site
    before_filter :prepare_context_locale, :except=>[:static, :data, :not_found]
    after_filter :log_current_context
    
    after_filter :store_user_recent
    
    def prepare_context_site
      Context.site = Site.find_by_host request.host
      if not Context.site
        render :inline=>"404: No site for host '#{request.host}' found.", :status=>404
        return false
      elsif Context.site.is_star? and self.class == Elastic::ElasticController
        render :template=>'/elastic/public/fallback', :layout=>false
      end
    end

    def prepare_context_locale
      Context.locale = params[:locale] || Context.site.index_locale || Context.site.locales.first
      if not Context.site.locales
        render :inline=>"Elastic CMS: no locales defined yet?"
        return false
      end
      if not Context.site.locales.include? Context.locale
        render :inline=>"Elastic CMS: invalid locale: '#{Context.locale}', use '#{Context.site.locales.join("' or '")}'"
        return false
      end 
      
      Context.user = current_user
      if Context.user
        I18n.locale = current_user.locale.blank? ? :en : current_user.locale
      end
    end
    
    def store_user_recent
      return if not current_user
      current_user.meta ||= {}
      x = current_user.meta[:recent] || []
      
      t = false
      if @item and !@item.new_record?
        the_link = editor_section_node_path(@item.section,@item) if @item.class == Node
        the_link = editor_gallery_path(@item) if @item.class == Gallery
        the_link = master_section_path(@item) if @item.class == Section
        the_link = master_site_path(@item) if @item.class == Site
      end
      
      if the_link
        x << [@item.to_nice, the_link, @item.class.to_s] 
        x = x.reverse.uniq.reverse
      end
      
      while x.size > 5
        x.shift
      end
      
      current_user.update_attribute :meta, current_user.meta.merge(:recent=> x)
    end
    
    def ensure_ownership
      Rails.logger.debug "ensure_ownership"
      for x in %w{ item node gallery section }
        var = instance_variable_get '@'+x
        if var and var.respond_to? :site_id and var.site_id!=Context.site.id
          redirect_to access_denied_path
          return false
        end
      end      
    end

    def default_url_options(options={})
  #    logger.debug "default_url_options is passed options: #{options.inspect}\n"
      { :locale => Context.locale } #||CurrentContex.site.index_locale
    end    

    def is_testing?
      true
    end
    
    # -- logging --

    def log_current_context
      logger.info current_context_info
    end

    def log_exception(x)
      logger.info "--[ exception ]------"
      logger.info "#{x.message}"
      logger.info "#{x.backtrace.join("\n")}"
      logger.info "---------------------"
    end

    def current_context_info
      ret =  "System context: "
#      ret << "User: #{current_user.id} " if current_user
      # ret << "Provider: #{current_provider.id} " if current_provider
      # ret << "Client: #{current_client.id} " if current_client
      ret << "#{@item.class}:#{@item.id}" if @item    
      ret
    end
    
    
    protected
    
    # --- users ---
    
    # def current_user
    #   @current_user ||= User.find_by_id(session[:user_id])
    # end
    # 
    # def signed_in?
    #   !!current_user
    # end
    # 
    # helper_method :current_user, :signed_in?
    # 
    # def current_user=(user)
    #   @current_user = user
    #   session[:user_id] = user.nil? ? user : user.id
    # end
  end
end
