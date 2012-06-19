class FileRecordDrop < Liquid::Drop

  def initialize(x)
    @file_record = x
  end

  for x in %w{ title filename path is_star? }
    module_eval "def #{x}; @file_record.#{x}; end"    
  end
  
  for x in %w{ orig img tna tnb }
    module_eval "def path_#{x}; @file_record.path('#{x}'); end"
  end
    
  def to_s
    @file_record.filename
  end
  
end
