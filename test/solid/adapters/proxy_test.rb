# frozen_string_literal: true

require "test_helper"

module Solid::Adapters
  class ProxyTest < Minitest::Test
    test "the Proxy ancestor" do
      assert_operator Proxy, :<, Core::Proxy::Base

      refute_operator Proxy, :<, Proxy::AlwaysEnabled
    end

    test "the Proxy::AlwaysEnabled ancestor" do
      assert_operator Proxy::AlwaysEnabled, :<, Core::Proxy::Base

      refute_operator Proxy::AlwaysEnabled, :<, Proxy
    end
  end
end
