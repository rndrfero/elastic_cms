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

  def nodes
#    @section.nodes.localized.published.map{ |x| NodeDrop.new(x) }
    if @section.localization == 'mirrored'
      @section.nodes.published.map{ |x| NodeDrop.new(x) }
    else
      @section.nodes.localized.published.map{ |x| NodeDrop.new(x) }
    end
  end

  def roots
    if @section.localization == 'mirrored'
      @section.nodes.roots.published.map{ |x| NodeDrop.new(x) }
    else
      @section.nodes.roots.localized.published.map{ |x| NodeDrop.new(x) }
    end
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