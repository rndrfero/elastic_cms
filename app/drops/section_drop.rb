class SectionDrop < Liquid::Drop

  def initialize(x)
    @section = x
#    Elastic::Context.ctrl.add_reference @section
  end

  for x in %w{ title key localization }
    module_eval "def #{x}; @section.#{x}; end"    
  end

  def path
    "/#{Elastic::Context.locale}/section/#{@section.key}"
  end
  
  def size
    if @section.localization == 'mirrored'
      @section.nodes.published.count
    else
      @section.nodes.localized.published.count
    end
  end

  def nodes
#    @section.nodes.localized.published.map{ |x| NodeDrop.new(x) }
    # if @section.localization == 'mirrored'
    #   @section.nodes.published.ordered.map{ |x| NodeDrop.new(x) }
    # else
    #   @section.nodes.localized.published.ordered.map{ |x| NodeDrop.new(x) }
    # end
    ret = @section.nodes.published
    ret = ret.localized if not @section.localization == 'mirrored'
    ret = ret.reorder('published_at DESC') if @section.form == 'blog'
    ret.map{ |x| NodeDrop.new(x) }
  end

  def roots
    # if @section.localization == 'mirrored'
    #   @section.nodes.roots.published.map{ |x| NodeDrop.new(x) }
    # else
    #   @section.nodes.roots.localized.published.ordered.map{ |x| NodeDrop.new(x) }
    # end

    ret = @section.nodes.roots.published
    ret = ret.localized if not @section.localization == 'mirrored'
    ret = ret.reorder('published_at DESC') if @section.form == 'blog'
    ret.map{ |x| NodeDrop.new(x) }
  end
  
# before_depth(depth)     Return nodes that are less deep than depth (node.depth < depth)
# to_depth(depth)         Return nodes up to a certain depth (node.depth <= depth)
# at_depth(depth)         Return nodes that are at depth (node.depth == depth)
# from_depth(depth)       Return nodes starting from a certain depth (node.depth >= depth)
# after_depth(depth)      Return nodes that are deeper than depth (node.depth > depth)

  def at_depth
    from = @section.nodes.published
    from = from.localized if not @section.localization == 'mirrored'

    ret = {}
    for n in from
      ret[n.ancestry_depth] ||= []
      ret[n.ancestry_depth] << NodeDrop.new(n)
    end
      
    ret
  end


  # def starry_nodes
  #   @section.nodes.starry.published.map{ |x| NodeDrop.new(x) }
  # end
  # 
  # def starry_roots
  #   @section.nodes.starry.published.map{ |x| NodeDrop.new(x) }
  # end

  # def roots
  #   @section.nodes.published.where( :node_id=>'NULL' ).map{ |x| NodeDrop.new(x) }
  # end

  def to_s
    @section.title
  end

  def ==(x)
    return false if not x.is_a? SectionDrop
    @section.id == x.instance_variable_get(:@section).id
  end

end