# frozen_string_literal: true

require "test_helper"

class Solid::AdaptersTest < Minitest::Test
  test ".config" do
    assert_same(Solid::Adapters::Core::Config.instance, Solid::Adapters.config)

    assert(Solid::Adapters.config.proxy_enabled)
    assert(Solid::Adapters.config.interface_enabled)

    assert_predicate(Solid::Adapters.config, :proxy_enabled?)
    assert_predicate(Solid::Adapters.config, :interface_enabled?)

    assert_equal({proxy_enabled: true, interface_enabled: true}, Solid::Adapters.config.options)
    assert_equal(
      "#<Solid::Adapters::Core::Config proxy_enabled=true, interface_enabled=true>",
      Solid::Adapters.config.inspect
    )
  end

  test ".configure" do
    assert_equal(Solid::Adapters.method(:configuration), Solid::Adapters.method(:configure))
  end

  test ".configuration(freeze: false)" do
    Solid::Adapters.configuration(freeze: false) do |config|
      assert_same(Solid::Adapters::Core::Config.instance, config)

      refute_predicate(config, :frozen?)
      assert_predicate(config, :proxy_enabled?)
      assert_predicate(config, :interface_enabled?)
    end
  end

  test ".configuration(freeze: true)" do
    config_instance = Solid::Adapters::Core::Config.new

    Solid::Adapters::Core::Config.expects(:instance).returns(config_instance).twice

    Solid::Adapters.configuration(freeze: true) do |config|
      assert_same(config_instance, config)

      refute_predicate(config, :frozen?)
      assert_predicate(config, :proxy_enabled?)
      assert_predicate(config, :interface_enabled?)
    end

    assert_predicate(config_instance, :frozen?)
  end
end
