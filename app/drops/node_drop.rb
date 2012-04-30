class NodeDrop < Liquid::Drop

  def initialize(x)
    @node = x
  end
  
  for x in %w{ title id key }
    module_eval "def #{x}; @node.#{x}; end"    
  end  
  
#  def title
#    @node.section.localization == 'mirrored' ? @node.title_loc[CurrentContext.locale] : @node.title_loc
#  end
  
  def path
    "/#{Elastic::Context.locale}/show/#{@node.key}"
  end
  
  def section
    SectionDrop.new @node.section
  end
  
  # -- contents --
  
  def contents
    @node.contents.map{ |x| ContentDrop.new x }
  end

  def content1
    index = 1-1
    return nil if index >= @node.contents.size
    ContentDrop.new @node.contents[index]
  end
  
  # -- navigation --
  
  def parent
    @node.parent ? NodeDrop.new(@node.parent) : nil
  end

  def root
    NodeDrop.new @node.root
  end
  
  for x in %w{ is_root? has_children? is_childless? has_siblings? is_only_child? depth }
    module_eval "def #{x}; @node.#{x}; end"    
  end  

  for x in %w{ ancestors children siblings descendants subtree }
    module_eval "def #{x}; @node.#{x}.published.map{ |x| NodeDrop.new x }; end"    
  end  
  # 
  # def children
  #   @node.children.map{ |x| NodeDrop.new x }
  # end
    
  
  
  
  def to_s
    @node ? @node.title : nil
  end

  def ==(x)
    @node.id == x.instance_variable_get(:@node).id
  end
  
end