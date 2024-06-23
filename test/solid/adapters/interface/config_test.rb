# frozen_string_literal: true

require "test_helper"

module Solid::Adapters::Interface
  class ConfigTest < Minitest::Test
    module Factory
      TEMPLATE = <<~RUBY
        include Solid::Adapters::Interface%s

        module Methods
          def add(a, b)
            a.is_a?(Integer) && b.is_a?(Integer) or raise("a and b must be integers")

            super
          end
        end
      RUBY

      def self.interface(always_enabled: false)
        compiled = format(TEMPLATE, always_enabled ? "::AlwaysEnabled" : "")

        Module.new.tap { _1.module_eval(compiled) }
      end
    end

    module Add
      def add(a, b)
        a + b
      end
    end

    module Adder
      extend Add
    end

    test "interface config (proxy side effect)" do
      assert ::Solid::Adapters.config.interface_enabled
      assert ::Solid::Adapters.config.interface_enabled?
      assert ::Solid::Adapters.config.options[:interface_enabled]

      interface1 = Factory.interface
      interface2 = Factory.interface(always_enabled: true)

      refute_same Adder, interface1[Adder]
      refute_same Adder, interface2[Adder]

      ins1 = Class.new { include(interface1, Add) }.new
      mod1 = Module.new { extend(interface1, Add) }

      ins2 = Class.new { include(interface2, Add) }.new
      mod2 = Module.new { extend(interface2, Add) }

      assert_raises(RuntimeError) { ins1.add("1", "1") }
      assert_raises(RuntimeError) { mod1.add("1", "1") }

      assert_raises(RuntimeError) { ins2.add("1", "1") }
      assert_raises(RuntimeError) { mod2.add("1", "1") }

      assert_equal 2, ins1.add(1, 1)
      assert_equal 2, mod1.add(1, 1)

      assert_equal 2, ins2.add(1, 1)
      assert_equal 2, mod2.add(1, 1)

      ::Solid::Adapters.config.interface_enabled = false

      refute ::Solid::Adapters.config.interface_enabled
      refute ::Solid::Adapters.config.interface_enabled?
      refute ::Solid::Adapters.config.options[:interface_enabled]

      interface3 = Factory.interface
      interface4 = Factory.interface(always_enabled: true)

      assert_same Adder, interface3[Adder]
      refute_same Adder, interface4[Adder]

      ins3 = Class.new { include(interface3, Add) }.new
      mod3 = Module.new { extend(interface3, Add) }

      ins4 = Class.new { include(interface4, Add) }.new
      mod4 = Module.new { extend(interface4, Add) }

      assert_equal "22", ins3.add("2", "2")
      assert_equal "22", mod3.add("2", "2")

      assert_raises(RuntimeError) { ins4.add("2", "2") }
      assert_raises(RuntimeError) { mod4.add("2", "2") }

      assert_equal 4, ins3.add(2, 2)
      assert_equal 4, mod3.add(2, 2)

      assert_equal 4, ins4.add(2, 2)
      assert_equal 4, mod4.add(2, 2)
    ensure
      ::Solid::Adapters.config.interface_enabled = true

      assert ::Solid::Adapters.config.interface_enabled
      assert ::Solid::Adapters.config.interface_enabled?
      assert ::Solid::Adapters.config.options[:interface_enabled]

      interface5 = Factory.interface
      interface6 = Factory.interface(always_enabled: true)

      refute_same Adder, interface5[Adder]
      refute_same Adder, interface6[Adder]

      ins5 = Class.new { include(interface5, Add) }.new
      mod5 = Module.new { extend(interface5, Add) }

      ins6 = Class.new { include(interface6, Add) }.new
      mod6 = Module.new { extend(interface6, Add) }

      assert_raises(RuntimeError) { ins5.add("3", "3") }
      assert_raises(RuntimeError) { mod5.add("3", "3") }

      assert_raises(RuntimeError) { ins6.add("3", "3") }
      assert_raises(RuntimeError) { mod6.add("3", "3") }

      assert_equal 6, ins5.add(3, 3)
      assert_equal 6, mod5.add(3, 3)

      assert_equal 6, ins6.add(3, 3)
      assert_equal 6, mod6.add(3, 3)
    end
  end
end
