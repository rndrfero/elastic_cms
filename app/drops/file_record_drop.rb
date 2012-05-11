class FileRecordDrop < Liquid::Drop

  def initialize(x)
    @file_record = x
  end

  for x in %w{ title filename path }
    module_eval "def #{x}; @file_record.#{x}; end"    
  end

  def path_orig
    path
  end
  
  for x in Elastic::Gallery::VARIANTS
    module_eval "def path_#{x}; @file_record.path('#{x}'); end"
  end
    
  def to_s
    @file_record.title
  end
  
end
