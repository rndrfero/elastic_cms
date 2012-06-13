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
    @contents ||= @node.contents.map do |x|
 
      if %w{ image node gallery }.include? x.content_config.form # we are referencing something
        ref = Elastic::Context.user ? x.reference : (x.published_reference||x.reference)
        if ref.nil?
          nil
        else
          Elastic::Context.ctrl.add_reference ref
          case ref.class.to_s
            when 'Elastic::FileRecord' then FileRecordDrop.new ref
            when 'Elastic::Gallery' then GalleryDrop.new ref
            when 'Elastic::Node' then NodeDrop.new ref
          end
        end
      else # standard content                
        ContentDrop.new(x)
      end
        
      # if x.reference.is_a? 
      #   FileRecordDrop.new x.reference
      # elsif x.reference.is_a? Elastic::Gallery
      #   GalleryDrop.new x.reference
      # elsif x.reference.is_a? Elastic::Node
      #   NodeDrop.new x.reference
      # else
      #   ContentDrop.new x
      # end
    end
  end
  
  def content
    contents
  end
  
    
  # -- navigation --
  
  def parent
    @node.parent ? NodeDrop.new(@node.parent) : nil
  end

  def root
    NodeDrop.new @node.root
  end
  
#  is_star? 
  
  for x in %w{ is_star? is_root? has_children? is_childless? has_siblings? is_only_child? depth }
    module_eval "def #{x}; @node.#{x}; end"    
  end  

  for x in %w{ ancestors children siblings descendants subtree }
    module_eval "def #{x}; @node.#{x}.published.map{ |x| NodeDrop.new x }; end"    
  end  
  
  def starry
    is_star?
  end
    
  def to_s
    @node ? @node.title : nil
  end

  def ==(x)
    return false if not x.is_a? NodeDrop
    @node.id == x.instance_variable_get(:@node).id
  end
  
end