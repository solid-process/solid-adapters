# frozen_string_literal: true

require_relative "adapters/version"

module Solid
  module Adapters
    module Core
      require_relative "adapters/core/config"
      require_relative "adapters/core/proxy"
    end

    require_relative "adapters/configurable"
    require_relative "adapters/interface"
    require_relative "adapters/proxy"

    def self.config
      Core::Config.instance
    end

    def self.configuration(freeze: true)
      yield(config)

      config.tap { _1.freeze if freeze }
    end

    singleton_class.send(:alias_method, :configure, :configuration)
  end
end
