require "elastic/engine"
require "elastic/context"
require "elastic/with_directory"
require "elastic/thumbnail_generators"

module Elastic
  def self.logger
    Rails.logger
  end
end
