# frozen_string_literal: true

module Solid::Adapters::Core
  class Config
    attr_accessor :proxy_enabled, :interface_enabled

    def initialize(proxy_enabled: true, interface_enabled: true)
      self.proxy_enabled = proxy_enabled
      self.interface_enabled = interface_enabled
    end

    def proxy_enabled?
      proxy_enabled
    end

    def interface_enabled?
      interface_enabled
    end

    def options
      {
        proxy_enabled: proxy_enabled,
        interface_enabled: interface_enabled
      }
    end

    def inspect
      "#<#{self.class.name} proxy_enabled=#{proxy_enabled}, interface_enabled=#{interface_enabled}>"
    end

    @instance = new

    singleton_class.send(:attr_reader, :instance)
  end
end
