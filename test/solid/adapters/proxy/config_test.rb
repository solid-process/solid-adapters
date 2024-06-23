# frozen_string_literal: true

require "test_helper"

class Solid::Adapters::Proxy::ConfigTest < Minitest::Test
  class ToggleableProxy < Solid::Adapters::Proxy
    def add(a, b)
      a.is_a?(Integer) && b.is_a?(Integer) or raise("a and b must be integers")

      object.add(a, b)
    end
  end

  class ProxyAlwaysEnabled < Solid::Adapters::Proxy::AlwaysEnabled
    def add(a, b)
      a.is_a?(Integer) && b.is_a?(Integer) or raise("a and b must be integers")

      object.add(a, b)
    end
  end

  module Adder
    def self.add(a, b)
      a + b
    end
  end

  test "proxy config" do
    assert Solid::Adapters.config.proxy_enabled
    assert Solid::Adapters.config.proxy_enabled?
    assert Solid::Adapters.config.options[:proxy_enabled]

    assert_raises(RuntimeError) { ToggleableProxy[Adder].add("1", "1") }
    assert_raises(RuntimeError) { ProxyAlwaysEnabled[Adder].add("1", "1") }

    assert_equal 2, ToggleableProxy[Adder].add(1, 1)
    assert_equal 2, ProxyAlwaysEnabled[Adder].add(1, 1)

    Solid::Adapters.config.proxy_enabled = false

    refute Solid::Adapters.config.proxy_enabled?
    refute Solid::Adapters.config.proxy_enabled
    refute Solid::Adapters.config.options[:proxy_enabled]

    assert_equal "12", ToggleableProxy[Adder].add("1", "2")
    assert_raises(RuntimeError) { ProxyAlwaysEnabled[Adder].add("1", "2") }

    assert_equal 4, ToggleableProxy[Adder].add(2, 2)
    assert_equal 4, ProxyAlwaysEnabled[Adder].add(2, 2)
  ensure
    Solid::Adapters.config.proxy_enabled = true

    assert Solid::Adapters.config.proxy_enabled
    assert Solid::Adapters.config.proxy_enabled?
    assert Solid::Adapters.config.options[:proxy_enabled]

    assert_raises(RuntimeError) { ToggleableProxy[Adder].add("1", "2") }
    assert_raises(RuntimeError) { ProxyAlwaysEnabled[Adder].add("1", "2") }

    assert_equal 6, ToggleableProxy[Adder].add(3, 3)
    assert_equal 6, ProxyAlwaysEnabled[Adder].add(3, 3)
  end
end
