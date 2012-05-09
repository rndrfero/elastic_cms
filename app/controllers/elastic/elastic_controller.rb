module Elastic
  class ElasticController < ApplicationController
    
    before_filter :prepare

    # index page
    def index
      # fetch whats happening
      where_to_go = (@site.locale_to_index_hash||{})[ Context.locale ]
      # render index template if blank

      if not where_to_go.blank?
        if where_to_go.to_i != 0
          @node = Node.find.where(:site_id=>@site.id,:id=>where_to_go)
        end
      end

      render_liquid @site.theme
    end

    # show node
    def show
      @node = Node.where(:site_id=>@site.id, :key=>params[:key]).first
      if @node 
        @section = @node.section
        render_liquid @site.theme
      else
        render_404
      end
    end

    def section
      @section = Section.where(:site_id=>@site.id, :key=>params[:key]).first
      if @section
        render_liquid @site.theme
      else
        render_404
      end
    end

    def access_denied
      render_access_denied
    end

    # serve static content
    def static
      filepath = params[:filepath]+'.'+params[:format]
      # priority:

      # # first find in /static
      # x = File.join @site.home_dir+'static/'+filepath
      # if File.exists? x
      #   render :file=>x, :layout=>false
      #   return
      # end

      # then find in /themes/$CURRENT_THEME 
      x = File.join @site.theme_dir + filepath
      if File.exists? x
        render :file=>x, :formats=>params[:format], :layout=>false, :content_type=>'text/css'
      else
        redirect_to '/404'
      end
    end
    
    def data
      filepath = params[:filepath]+'.'+params[:format]
      x = File.join @site.home_dir, 'galleries', filepath
      if File.exists? x
        send_file x, :formats=>params[:format], :disposition=>'inline'# , :content_type=>'text/css'
      else
        redirect_to '/404'
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

    def render_liquid(template_name, add_drops={})
      # node_drop = NodeDrop.new @node
      # section_drop = SectionDrop.new @node.section

      if template_name.blank?
        render_error 'Dont know what to render. Check your theme configuration.'
        return
      end

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

      out = TemplateCache.render template_name, drops.merge!(add_drops)
      render :text=>out, :layout=>"/elastic/public/html5"
    end

    def render_error(error)
      render :inline=>"ERROR: #{error}"
    end

    def render_404(error)
      render :inline=>"404 - not found: #{error}", :status=>404
    end

    def render_access_denied
      render :inline=>"Sorry, access denied. Request with context logged."
    end
  end
end
