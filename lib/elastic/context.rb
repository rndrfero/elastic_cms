module Elastic
  module Context

    def self.site=(x)
      @@site = x
    end

    def self.site
      @@site
    end

    def self.locale=(x)
      @@locale = x
    end

    def self.locale
      @@locale
    end

    def self.user=(x)
      @@user = x
    end

    def self.user
      @@user
    end

  end
end
