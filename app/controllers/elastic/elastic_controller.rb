module Elastic
  class ElasticController < Elastic::ApplicationController
    
    skip_before_filter :authenticate_user!
    before_filter :prepare
    
    helper :wake
    include ElasticHelper

    # index page
    def index
      # fetch whats happening
      @node = @site.index_node
      if @node
        redirect_or_render_node
      else
        x = @site.locale_to_index_hash[Context.locale]
        if x =~ /^(\/|http:\/\/|https:\/\/)/
          redirect_to x
        else
          raise 'wtf'
        end
      end
    end

    # show node
    def show
      @node = Node.in_public.find_by_key params[:key]
      redirect_or_render_node
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
      @edit = true
      send @action
    end
    
    def update
      if @action == 'show'
        @node = Node.in_public.find_by_key params[:key]
      elsif @action == 'section'
        @section = @site.sections.find_by_key params[:key]
      elsif @action == 'index'
        # do nothing
      elsif @action == 'liquid'
        # do nothing
      else
        raise 'UNEXPECTED'
      end
      
      c = Content.find_by_id(params[:content_id])
      if c
        c.node.contents_setter= { c.content_config_id => params[:node] }
        if c.node.save
          flash[:hilite] = 'ok'
          redirect_to exit_path
        else
          flash.now[:notice] = 'error'
          edit
        end
      else
        raise 'UNEXPECTED'
      end
    end
    

    def access_denied
      render_access_denied
    end

    # serve static content
    def static
      Elastic.logger_info "POZOR! You are using ElasticController.static Setup your web server instead."
      filepath = params[:filepath]+'.'+params[:format]
      filepath.gsub!(RegexFilepath, '')
      
      x = File.join @site.home_dir + filepath
      if File.exists? x
        send_file x, :disposiotion=>'inline' #:formats=>params[:format], :layout=>false, :content_type=>'text/css'
      else
        render_404
      end
    end
    
    def liquid
      filepath = "#{params[:filepath]}.liquid"
      filepath.gsub!(RegexFilepath, '')
      x = File.join @site.home_dir + filepath

      if File.exists? x
        render_liquid filepath
      else
        render_404 filepath
      end
    end
      
    # def not_found
    #   render :inline=>"404: NOT FOUND", :status=>404
    # end
        
    def toggle_reload
      @site.toggle_reload!
      redirect_to :back
    end
    
    # -- non-action methods --
    
    def am_i_editing_this_shit?
      @edit and Context.user and Context.content and Context.content.id == params[:content_id].to_i
    end
    
    def add_reference(x)
      @references ||= []
      @references << x if not @references.include? x
    end    

    # -- private ---

    private
    
    def redirect_or_render_node
      if @node and !@node.redirect.blank?
        redirect_to @node.redirect #if @node.redirect =~ /(http|https|ftp).*/
      elsif @node
        @section = @node.section
        render_liquid
      else
        render_404
      end
    end    
    
    def prepare
      Context.ctrl= self
      @site = Context.site
      
      @site.copy_themes! if ELASTIC_CONFIG['copy_themes']
      
      if %w{ edit update }.include? params[:action]
        @action = request.path.split('/')[2]
      else
        @action = params[:action]
      end
      
      
      if @site.theme.blank?
        render_error "There is no theme selected. There is nothing to render."
        return false
      end
    end

    def render_liquid(template_name=nil, add_drops={})
      # node_drop = NodeDrop.new @node
      # section_drop = SectionDrop.new @node.section
      x = @action=='index' ? @site.theme_index : @site.theme_template
      template_name ||=  x.blank? ? 'current_theme/'+@site.theme+'.liquid' : 'current_theme/'+x
      

      drops = {
        'test' => "This is a test.",

        'site' => SiteDrop.new(@site),
        'node' => (@node ? NodeDrop.new(@node) : nil),
        'section' => (@section ? SectionDrop.new(@section) : nil),

        'theme' => @site.theme,

        'params' => params,
        'locale' => Context.locale.to_s,
        'action' => @action,
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
      
        @head = TemplateCache.render 'current_theme/head.liquid' , drops if File.exists?(@site.theme_dir+'head.liquid')
      
        if @site.theme_layout.blank?
          render :text=>out, :layout=>"/elastic/public/html5"
        else      
          controls = render_to_string :partial=>'/elastic/public/controls'
          out = TemplateCache.render @site.theme_layout, { 'head'=>@head, 'body'=>out, 'controls'=>controls }
          render :text=>out, :layout=>false        
        end
      rescue Errno::ENOENT=>x
         render_error x.message.gsub @site.home_dir, '/'
      rescue Liquid::SyntaxError=>x
         render_error "Elastic CMS: Liquid syntax error: #{x}"
      end
    end
    
    
    
    def render_error(error)
      render :inline=>"Elastic CMS: #{error}", :layout=>'elastic/error'
    end

    def render_404(error=nil)
      render :inline=>(error ? "Elastic CMS: 404 - not found: '#{error}'" : "Elastic CMS: 404 - not found"), :status=>404
    end

    def render_access_denied
      render :inline=>"Elastic CMS: Sorry, access denied."
    end
    
    def postprocess(out, template_name)
      return BlueCloth.new(out).to_html if template_name.ends_with? '.md'
      return out = `echo '#{out}' | php` if template_name.ends_with? '.php'
      out
    end
        
  end
end
