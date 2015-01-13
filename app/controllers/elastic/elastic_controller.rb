require 'open3'

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
        x = (@site.locale_to_index_hash||{})[Context.locale]
        if x =~ /^(\/|http:\/\/|https:\/\/)/
          redirect_to x
        else
          render_liquid #raise 'wtf'
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
      @content = Content.find_by_id(params[:content_id])
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
        #send_file x, :disposiotion=>'inline' #:formats=>params[:format], :layout=>false, :content_type=>'text/css'
        send_file x, :disposition=>'inline' #:formats=>params[:format], :layout=>false, :content_type=>'text/css'
      else
        render_404
      end
    end
    
    def liquid_layout
      filepath = secure_filepath "#{params[:filepath]}.liquid"

      if File.exists? @site.home_dir + filepath
        render_liquid filepath
      else
        render_404 filepath
      end
    end
    
    def liquid_nolayout
      filepath = secure_filepath"#{params[:filepath]}.liquid"

      if File.exists? @site.home_dir + filepath
        render_liquid filepath, {}, :layout=>false
      else
        render_404
      end
    end

    def scss
      filepath = secure_filepath "#{params[:filepath]}"

      scss = File.join @site.home_dir, filepath+'.scss'
      css = File.join @site.home_dir, filepath+'.css'

      return render_404 if not File.exists? scss

      if !File.exists?(css) or File.mtime(scss) > (mtime=File.mtime(css))
        Rails.logger.debug "rendering SCSS: #{filepath} "
        Open3.popen3("sass -l #{scss} &> #{css}") do |stdin, stdout, stderr, wait_thr|
          stdin.close
        end
      end      

      send_file css, :disposition=>'inline' #, :content_type=>'text/css'      
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
      @locale = Context.locale
      
#      params[:key] = params[:key]+'.'+params[:format] if params[:format]
      
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

    def render_liquid(template_name=nil, add_drops={}, options={})
      # redirection catch
      #raise @redirect_tag_to.to_yaml
      #Rails.logger.info "---- redir tag: #{@redirect_tag_to}"
      

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
        'locale' => @locale.to_s,
        'action' => @action,
        'key' => params[:key],
        'user' => (Context.user ? Context.user.name : nil),
        'localhost' => '',
        'now' => Time.now.to_i 
      }

      for s in @site.sections
        drops.merge!( { "section_#{s.key}" => SectionDrop.new(s) })
      end
      drops.merge! add_drops
      
      begin # rendering block
        
        out = TemplateCache.render template_name, drops
        
        # ----- LEVEL 2 rendering -----
        if not @edit
          out = Liquid::Template.parse out
          out = out.render drops
        end
        # ----- LEVEL 2 rendering -----
        
        out = postprocess out, template_name
      
        @head = TemplateCache.render 'current_theme/head.liquid' , drops if File.exists?(@site.theme_dir+'head.liquid')
      
        if @redirect_tag_to
          redirect_to @redirect_tag_to
        elsif options[:layout] == false
          render :text=>out, :layout=>false
        elsif @site.theme_layout.blank?
          render :text=>out, :layout=>"/elastic/public/html5"
        else      
          controls = render_to_string :partial=>'/elastic/public/controls'
          out = TemplateCache.render @site.theme_layout, { 'head'=>@head, 'body'=>out, 'controls'=>controls }
          render :text=>out, :layout=>false        
        end
        
      rescue Errno::ENOENT=>x
         render_error x.message.gsub @site.home_dir, '/'
      rescue Liquid::SyntaxError=>x
         render_error "Liquid syntax error: #{x}"
      end
    end
    
    
    
    def render_error(error)
      render inline: "#{error}", layout: 'elastic/error', status: 500
    end

    def render_404(error=nil)
      render inline: (error ? "Elastic CMS: 404 - not found: '#{error}'" : "Elastic CMS: 404 - not found"), status: 404
    end

    # def render_500(error=nil)
    #   render inline: (error ? "Elastic CMS: 500 - error: \n '#{error}'" : "Elastic CMS: 500 - error"), status: 500
    # end

    def render_access_denied
      render :inline=>"Elastic CMS: Sorry, access denied."
    end
    
    def postprocess(out, template_name)
      return BlueCloth.new(out).to_html if template_name.ends_with? '.md'
      return out = `echo '#{out}' | php` if template_name.ends_with? '.php'
      out
    end

    # -- -- -- private erotic stuff -- -- --

    private

    def secure_filepath(filepath)      
      secure_filepath = filepath.gsub(RegexFilepath, '')
    end
        
  end
end
