class SectionDrop < Liquid::Drop

  def initialize(x)
    @section = x
  end

  for x in %w{ title key localization }
    module_eval "def #{x}; @section.#{x}; end"    
  end

  def path
    "/#{Elastic::Context.locale}/section/#{@section.key}"
  end

  def nodes
    @section.nodes.published.map{ |x| NodeDrop.new(x) }
  end

  def roots
    @section.nodes.roots.published.map{ |x| NodeDrop.new(x) }
  end

  # def roots
  #   @section.nodes.published.where( :node_id=>'NULL' ).map{ |x| NodeDrop.new(x) }
  # end

  def to_s
    @section.title
  end

  def ==(x)
    @section.id == x.instance_variable_get(:@section).id
  end

end