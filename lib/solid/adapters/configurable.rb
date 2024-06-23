# frozen_string_literal: true

module Solid::Adapters
  module Configurable
    require_relative "configurable/options"

    def config
      @config ||= Options.new
    end

    def configuration(freeze: true)
      yield(config)

      config.tap { _1.freeze if freeze }
    end

    alias_method :configure, :configuration
  end
end
