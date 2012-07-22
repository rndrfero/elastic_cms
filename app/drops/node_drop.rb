class NodeDrop < Liquid::Drop

  def initialize(x)
    @node = x
  end
  
  for x in %w{ id key redirect is_star? }
    module_eval "def #{x}; @node.#{x}; end"    
  end  
  
  def title
    @node.title_dynamic
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
    @contents ||= @node.section.content_configs.map do |x|
      c = @node.content_getter x
      if not c
        nil
      elsif %w{ image node gallery }.include? x.form # we are referencing something
        ref = Elastic::Context.user ? c.reference : (c.published_reference||c.reference)
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
        ContentDrop.new(c)
      end
    end
  end
  
  
  def _content(position)  
    x = @node.section.content_configs.where(:position=>position+1).first
    c = @node.content_getter x #_position position
    if not c
      nil
    elsif %w{ image node gallery }.include? x.form # we are referencing something
      ref = Elastic::Context.user ? c.reference : (c.published_reference||c.reference)
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
      ContentDrop.new(c)
    end    
  end
    
  
  0.upto(ELASTIC_CONFIG['max_contents']) do |index|
    define_method "content#{index}" do
      _content(index)
    end
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
  
  # def is_star?
  # end
    
  def to_s
    @node ? @node.title_dynamic : nil
  end

  def ==(x)
    return false if not x.is_a? NodeDrop
    @node.id == x.instance_variable_get(:@node).id
  end
  
end