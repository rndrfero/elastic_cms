module Elastic
  class ApplicationController < ActionController::Base
    
    layout 'elastic/backend'

    before_filter :prepare_context
    after_filter :log_current_context

    def prepare_context
      Context.locale = params[:locale] || I18n.default_locale
      Context.site = Site.find_by_host request.host
      if not Context.site
        render :inline=>"404: No site for host '#{request.host}' found.", :status=>404
        return false
      end
      if not Context.site.locales.include? Context.locale
        redirect_to params.merge! :locale=>Context.site.locales.first
        return false
      end if Context.site.locales
#      Context.user = current_user
      logger.debug "--> TU TREBA DOROBIT CI MU PATRI DANA SITE ALEBO NIE"
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
    
    
  end
end
