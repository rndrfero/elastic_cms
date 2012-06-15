require "elastic/engine"
require "elastic/context"
require "elastic/with_directory"
require "elastic/thumbnail_generators"
require "elastic/string"
require "elastic/tincan"

require "elastic/liquid_hacks"
require "elastic/liquid_tags"
require "elastic/liquid_filters"

module Elastic
  
  def self.logger_info(x)
    Rails.logger.info "* Elastic CMS: #{x}"
  end
end
