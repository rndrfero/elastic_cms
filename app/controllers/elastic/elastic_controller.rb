module Elastic
  class ElasticController < Elastic::ApplicationController
    
    skip_before_filter :authenticate_user!
    before_filter :prepare
    
    helper :wake

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
      render_liquid 
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
    
    def edit
      show
    end
    
    def update
      @node = Node.in_public.find_by_key params[:key]
      if @node
        @node.contents_setter= { params[:content_config_id]=>params[:node] }
        if @node.save
          flash[:hilite] = 'ok'
          redirect_to show_path(@node.key)
        else
          flash.now[:notice] = 'error'
          edit
        end
      else
        raise 'KOKOTINA'
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
    
    def toggle_reload
      @site.toggle_reload!
      redirect_to :back
    end
    
    # -- non-action methods --
    
    def add_reference(x)
#      raise x.to_yaml
      @references ||= []
      @references << x if not @references.include? x
    end    

    private
    def prepare
      @site = Context.site
      Context.ctrl= self
      
      if @site.theme.blank?
        render_error "There is no theme selected. There is nothing to render."
        return false
      end
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
        'user' => (Context.user ? Context.user.name : nil)
      }

      for s in @site.sections
        drops.merge!( { "section_#{s.key}" => SectionDrop.new(s) })
      end
      drops.merge! add_drops
      
      begin # rendering block
        
        out = TemplateCache.render template_name, drops
        out = postprocess out, template_name
      
        @head = TemplateCache.render 'head' , drops if File.exists?(@site.theme_dir+'head.liquid')
      
        if @site.theme_layout.blank?
          render :text=>out, :layout=>"/elastic/public/html5"
        else      
          controls = render_to_string :partial=>'/elastic/public/controls'
          out = TemplateCache.render @site.theme_layout, { 'head'=>@head, 'body'=>out, 'controls'=>controls }
          render :text=>out, :layout=>false        
        end
      rescue Errno::ENOENT=>x
         render_error x.message.gsub @site.home_dir, '/'
#        render :inline
      rescue Liquid::SyntaxError=>x
#        render :inline=>"<h3>Liquid syntax error:</h3> <p>#{x}</p>"
         render_error "Liquid syntax error: #{x}"
      end
    end
    
    
    
    def render_error(error)
      render :inline=>"#{error}", :layout=>'elastic/error'
    end

    def render_404(error=nil)
      render :inline=>"404 - not found #{error}", :status=>404
    end

    def render_access_denied
      render :inline=>"Sorry, access denied."
    end
    
    def postprocess(out, template_name)
      return BlueCloth.new(out).to_html if template_name.ends_with? '.md'
      return out = `echo '#{out}' | php` if template_name.ends_with? '.php'
      out
    end
        
  end
end
