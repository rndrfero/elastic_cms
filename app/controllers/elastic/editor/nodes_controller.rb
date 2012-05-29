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
    
    def drop
      to_node = @section.nodes.find(params[:node_id])
      if @item.subtree_ids.include? to_node.id
        flash[:error] = 'No.'
      else
        @item.update_attribute :parent_id, to_node.id
        @section.fix_positions!
        flash[:hilite] = 'Yes!'
      end
      redirect_to :back
    end
    
    def reify
      xchg = @item.published_version_id
      @item = @version.reify if @version
      @item.published_version_id = xchg
      
      if @item and @version        
        for c in @item.contents
          old_c = c.version_at @version.created_at
#          old_c ||= c.versions.last.reify
          c.text = old_c ? old_c.text : nil
          c.reference_id = old_c ? old_c.reference_id : nil
          c.reference_type = old_c ? old_c.reference_type : nil
        end
        flash.now[:hilite] = 'Ressurection...'
      else
        flash.now[:error] = 'Cannot ressurect ...'
        @version = nil
        @item ||= Node.find params[:id]
      end
            
      render :action=>'node_form'
    end
    
    def publish_version
    end
    
    def restore      
      flash[:notice] = 'May you find what you seek, my friend ...'      
      @nodes = @section.reify_nodes
    end
    
    def publish_version
      if @item and @version
        @item.publish_version! @version
        flash[:hilite] = 'Published'
        redirect_to :action=>'reify', :id=>@item.id, :version_id=>@version.id
      else
        flash.now[:error] = 'Sorry, failed.'
        render :action=>'node_form'
      end
    end
    
    def publish_recent
      @item.publish_recent!
      flash[:hilite] = 'You are back in the recent edit.'
      redirect_to :action=>'edit', :id=>@item.id
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
      if @section.form == 'tree'
        @items = @items.tree_ordered.where(:section_id=>@section.id)
      elsif @section.form == 'blog'
        @items = @items.date_ordered.where(:section_id=>@section.id)
      end
      @items = @items.localized if @section.localization == 'free'
    end


    private
    def prepare        
      logger.debug "NodesController PREPARE"
      # not my section
#       if not @section or not Context.site.section_ids.include? @section.id
# #        raise rereferer.to_yaml
#         redirect_to access_denied_path 
#         return false
#       end
      if @item
        @item.section ||= @section
        @item.locale ||= Context.locale if @section.localization == 'free'
        @node = @item
      end
    end

  end
end