# frozen_string_literal: true

require "test_helper"

class Solid::Adapters::ConfigurableTest < Minitest::Test
  class Foo
    extend Solid::Adapters::Configurable

    NUMBERS = [1, 2, 3].freeze

    config.bar = nil
    config.biz = nil
    config.number { NUMBERS.sample }
  end

  module Bar
    extend Solid::Adapters::Configurable

    config.foo = nil
  end

  test ".config" do
    assert_nil Foo.config.bar

    refute Foo.config.key?(:foo)
    assert Foo.config.key?(:bar)

    number = Foo.config.number

    assert_includes Foo::NUMBERS, number

    assert_equal([:bar, :biz, :number], Foo.config.to_h.keys.sort)
    assert_nil(Foo.config.to_h[:bar])
    assert_nil(Foo.config.to_h[:biz])
    assert_kind_of(Proc, Foo.config.to_h[:number])

    assert_raises(KeyError) { Foo.config.fetch(:foo) }
    assert_equal "default", Foo.config.fetch(:foo) { "default" }

    assert_nil Foo.config[:bar]

    assert_nil Foo.config.fetch(:bar)
    assert_nil(Foo.config.fetch(:bar) { "default" })

    assert_nil Foo.config.bar
    assert_nil Foo.config.biz

    assert_respond_to Foo.config, :bar
    assert_respond_to Foo.config, :bar=
    assert_respond_to Foo.config, :biz
    assert_respond_to Foo.config, :biz=

    assert_respond_to Foo.config, :foo=
    refute_respond_to Foo.config, :foo

    Foo.config.bar = "BAR"

    assert_equal "BAR", Foo.config.bar
    assert_equal "BAR", Foo.config[:bar]
    assert_equal "BAR", Foo.config.fetch(:bar)

    assert_equal("BAR", Foo.config.to_h[:bar])
    assert_nil(Foo.config.to_h[:biz])
    assert_kind_of(Proc, Foo.config.to_h[:number])
  end

  test ".configuration(freeze: false)" do
    Foo.configuration(freeze: false) do |config|
      refute_predicate config, :frozen?

      config.bar = "BAR"
      config.biz = "BIZ"
    end

    assert_equal "BAR", Foo.config.bar
    assert_equal "BIZ", Foo.config.biz

    refute_predicate Foo.config, :frozen?
  ensure
    Foo.config.bar = nil
    Foo.config.biz = nil
  end

  test ".configuration(freeze: true)" do
    Bar.configuration(freeze: true) do |config|
      refute_predicate config, :frozen?

      config.foo = "FOO"
    end

    assert_equal "FOO", Bar.config.foo

    assert_predicate Bar.config, :frozen?
  end

  test ".configure" do
    assert_equal(Foo.method(:configure), Foo.method(:configuration))

    assert_equal(Bar.method(:configure), Bar.method(:configuration))
  end
end
