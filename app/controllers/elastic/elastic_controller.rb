module Elastic
  class ElasticController < Elastic::ApplicationController
    
    skip_before_filter :authenticate_user!
    before_filter :prepare

    # index page
    def index
      # fetch whats happening
      where_to_go = (@site.locale_to_index_hash||{})[ Context.locale ]
      # render index template if blank

      if not where_to_go.blank?
        if where_to_go.to_i != 0
          @node = Node.in_public.find_by_id where_to_go
        end
      end

#      raise 'fuck'
      render_liquid 
#      render_liquid @site.theme
    end

    # show node
    def show
      @node = Node.in_public.find_by_key params[:key]
      if @node and !@node.redirect.blank?
        redirect_to @node.redirect #if @node.redirect =~ /(http|https|ftp).*/
      elsif @node
        @section = @node.section
        render_liquid
      else
        render_404
      end
    end

    def section
      @section = Section.where(:site_id=>@site.id, :key=>params[:key]).first
      if @section
        render_liquid
      else
        render_404
      end
    end

    def access_denied
      render_access_denied
    end

    # serve static content
    def static
      Elastic.logger_info "POZOR! You are using ElasticController.static Setup your web server instead."
      filepath = params[:filepath]+'.'+params[:format]
      
      x = File.join @site.home_dir + filepath
      if File.exists? x
        send_file x, :disposiotion=>'inline' #:formats=>params[:format], :layout=>false, :content_type=>'text/css'
      else
        render_404
      end
    end
      
    def not_found
      render :inline=>"404: NOT FOUND", :status=>404
    end

    private
    def prepare
      @site = Context.site
      @site.integrity!
    end

    def render_liquid(template_name=nil, add_drops={})
      # node_drop = NodeDrop.new @node
      # section_drop = SectionDrop.new @node.section
      template_name ||= @site.theme_index.blank? ? @site.theme : @site.theme_index
      

      drops = {
        'test' => "This is a test.",

        'site' => SiteDrop.new(@site),
        'node' => (@node ? NodeDrop.new(@node) : nil),
        'section' => (@section ? SectionDrop.new(@section) : nil),

        'theme' => @site.theme,

        'params' => params,
        'locale' => Context.locale.to_s,
        'action' => params[:action],
        'key' => params[:key],
      }

      for s in @site.sections
        drops.merge!( { "section_#{s.key}" => SectionDrop.new(s) })
      end
      drops.merge! add_drops
      
      out = TemplateCache.render template_name, drops
      out = postprocess out, template_name
      
      @head = TemplateCache.render 'head' , drops
      
      if @site.theme_layout.blank?
        render :text=>out, :layout=>"/elastic/public/html5"
      else      
        controls = render_to_string :partial=>'/elastic/public/controls'
        out = TemplateCache.render @site.theme_layout, { 'head'=>@head, 'body'=>out, 'controls'=>controls }
        render :text=>out, :layout=>false        
      end
    end
    
    
    
    def render_error(error)
      render :inline=>"ERROR: #{error}"
    end

    def render_404(error=nil)
      render :inline=>"404 - not found #{error}", :status=>404
    end

    def render_access_denied
      render :inline=>"Sorry, access denied. Request with context logged."
    end
    
    def postprocess(out, template_name)
      return BlueCloth.new(out).to_html if template_name.ends_with? '.md'
      return out = `echo '#{out}' | php` if template_name.ends_with? '.php'
      out
    end
    
  end
end
