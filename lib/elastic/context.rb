module Elastic
  module Context

    def self.site=(x)
      @@site = x
    end

    def self.site
      @@site
    end

    def self.content=(x)
      @@content = x
    end

    def self.content
      @@content
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

    def self.ctrl=(x)
      @@ctrl = x
    end

    def self.ctrl
      @@ctrl
    end

  end
end
