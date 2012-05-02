module Elastic
  module WithDirectory

    def self.included(base)
      base.send :validates_format_of, :key, :allow_blank=>true, :with=>/^[a-zA-Z0-9_-]*$/
    end
  
    def create_or_rename_dir!(the_dir)
      return if Dir.exists? the_dir
      # find if it was not renamed
      old_dir = Dir.entries( File.dirname(the_dir) ).detect { |x| x=~/^#{id}\-/ }      
      if old_dir
        FileUtils.mv File.join(File.dirname(the_dir),old_dir), the_dir
      else
        FileUtils.mkdir_p the_dir
      end            
    end

  end
end