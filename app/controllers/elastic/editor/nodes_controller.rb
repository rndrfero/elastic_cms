module Elastic
  class Editor::NodesController < ApplicationController
  
    wake :within_module=>'Elastic'
  
    before_filter :prepare

    def toggle_published
      @item.toggle_published!
      flash[:hilite] = 'Yes!'
      redirect_to :back
    end

    def toggle_star
      @item.toggle_star!
      flash[:hilite] = 'Yes!'
      redirect_to :back
    end

    def toggle_locked
      @item.toggle_locked!
#      raise 'fuck'
      flash[:hilite] = 'Yes!'
      redirect_to :back
    end
  
    def move_higher
      @item.move_higher
      flash[:hilite] = 'Yes!'
      redirect_to :back
    end

    def move_lower
      @item.move_lower
      flash[:hilite] = 'Yes!'
      redirect_to :back
    end
    
    def reify
#      raise params.inspect
      @version = Version.find params[:version_id]
      @item = Version.find(params[:version_id]).reify if @version
      
      if @item and @version        
        for c in @item.contents
          old_c = c.version_at @version.created_at
          c.text, c.binary = old_c.text, old_c.binary
        end
        flash.now[:hilite] = 'Ressurection...'
      else
        flash.now[:error] = 'Cannot ressurect ...'
      end
      
      @item ||= Node.find params[:id]
      render :action=>'node_form'
    end
  
  
    def new
      @item = Node.new :section=>@section
#      raise "#{@item.section.inspect}"
    
      if @item.new_record? and @item.contents.empty?
        for x in @section.content_configs
          if @section.localization == 'mirrored'
            for l in Context.site.locales
              @item.contents << Content.new(:content_config=>x, :node=>@item, :locale=>l)
            end
          else
            @item.contents << Content.new(:content_config=>x, :node=>@item)
          end
        end
      end
    
  #    raise "p: #{@item.section.inspect}"
      super
    end
    
    def create
      @item = Node.new :section=>@section
#      @item.section= @section
      super
    end
  
    def wake_list
      super
      @items = @items.ordered.where(:section_id=>@section.id)
      @items = @items.localized if @section.localization == 'free'
    end


    private
    def prepare        
      logger.debug "NodesController PREPARE"
      # not my section
      if not @section or not Context.site.section_ids.include? @section.id
        redirect_to access_denied_path 
        return false
      end
      if @item
        @item.section ||= @section
        @item.locale ||= Context.locale if @section.localization == 'free'
        @node = @item
      end
    end

  end
end