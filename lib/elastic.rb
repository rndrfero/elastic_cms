require "elastic/engine"
require "elastic/context"
require "elastic/with_directory"
require "elastic/thumbnail_generators"
require "elastic/liquid_tags"
require "elastic/liquid_filters"
require "elastic/string"

module Elastic
  
  def self.logger_info(x)
    Rails.logger.info "* Elastic CMS: #{x}"
  end
end
