module Elastic
  module WithDirectory

    def self.included(base)
      base.send :validates_format_of, :key, :allow_blank=>true, :with=>/^[a-zA-Z0-9_-]*$/
    end
  
    def create_or_rename_dir!(the_dir, old_dir)      
      
      raise RuntimeError if the_dir.blank?
      exists = Dir.exists? the_dir
      chg = !old_dir.blank? && the_dir!=old_dir

#      raise "'#{the_dir}' / '#{old_dir}' |#{the_dir!=old_dir}| ex:#{exists} chg:#{chg}"
      
      if exists and !chg        
        # nothing to do
      elsif exists and chg
        # copy to existing directory & delete
        Elastic.logger_info "move to existing: #{old_dir} -> #{the_dir}"
        FileUtils.mv Dir.glob(File.join old_dir, '*' ), the_dir
      elsif !exists and chg
        Elastic.logger_info "move: #{old_dir} -> #{the_dir}"
        # rename
        FileUtils.mv old_dir, the_dir
      elsif !exists and !chg
        # create
        Elastic.logger_info "create: #{the_dir}"
        FileUtils.mkdir_p the_dir
      end            
    end    

  end
end