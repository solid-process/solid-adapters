# frozen_string_literal: true

require "delegate"

module Solid::Adapters
  module Interface
    module Callbacks
      def extended(impl)
        impl.singleton_class.prepend(self::Methods)
      end

      def included(impl)
        impl.prepend(self::Methods)
      end
    end

    module ClassMethods
      def [](object)
        const_get(:Proxy, false).new(object).extend(self)
      end
    end

    module ProxyDisabled
      extend Core::Proxy::ClassMethods

      def self.new(object)
        object
      end
    end

    DEFINE = lambda do |interface, enabled:|
      proxy = ProxyDisabled

      if enabled
        proxy = ::Class.new(::SimpleDelegator)
        proxy.extend(Core::Proxy::ClassMethods)

        interface.extend(Callbacks)
      end

      interface.const_set(:Proxy, proxy)
      interface.extend(ClassMethods)
    end

    def self.included(interface)
      DEFINE[interface, enabled: Core::Config.instance.interface_enabled]
    end

    module AlwaysEnabled
      def self.included(interface)
        DEFINE[interface, enabled: true]
      end
    end

    private_constant :Callbacks, :ClassMethods, :ProxyDisabled, :DEFINE
  end
end
