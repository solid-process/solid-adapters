# frozen_string_literal: true

require "test_helper"

module Solid::Adapters
  class InterfaceProxyTest < Minitest::Test
    module CalcInterface
      include Solid::Adapters::Interface

      module Methods
        def add(a, b)
          a.is_a?(Float) && b.is_a?(Float) or raise "a and b must be floats"

          super.tap { _1.finite? or raise format("%p must be a finite float", _1) }
        end
      end
    end

    module CalcInterfaceAlwaysEnabled
      include Solid::Adapters::Interface::AlwaysEnabled

      module Methods
        def add(a, b)
          a.is_a?(Float) && b.is_a?(Float) or raise "a and b must be floats"

          super.tap { _1.finite? or raise format("%p must be a finite float", _1) }
        end
      end
    end

    class Calc
      def add(a, b)
        a + b
      end
    end

    module CalcMod
      def self.add(a, b)
        a + b
      end
    end

    test "inteface proxy" do
      refute_kind_of(CalcInterface, Calc.new)
      refute_kind_of(CalcInterface, CalcMod)

      refute_kind_of(CalcInterfaceAlwaysEnabled, Calc.new)
      refute_kind_of(CalcInterfaceAlwaysEnabled, CalcMod)

      calc1 = CalcInterface[Calc.new]
      calc_mod1 = CalcInterface[CalcMod]

      calc2 = CalcInterfaceAlwaysEnabled[Calc.new]
      calc_mod2 = CalcInterfaceAlwaysEnabled[CalcMod]

      assert_kind_of(CalcInterface, calc1)
      assert_kind_of(CalcInterface, calc_mod1)

      assert_kind_of(CalcInterfaceAlwaysEnabled, calc2)
      assert_kind_of(CalcInterfaceAlwaysEnabled, calc_mod2)

      assert_raises(RuntimeError, "a and b must be floats") { calc1.add(1, 2.0) }
      assert_raises(RuntimeError, "a and b must be floats") { calc_mod1.add(1.0, 2) }
      assert_raises(RuntimeError, "a and b must be floats") { calc2.add(1, 2.0) }
      assert_raises(RuntimeError, "a and b must be floats") { calc_mod2.add(1.0, 2) }

      assert_raises(RuntimeError, "NaN must be a finite float") { calc1.add(Float::NAN, 2.0) }
      assert_raises(RuntimeError, "Infinity and b must be floats") { calc_mod1.add(1.0, Float::INFINITY) }
      assert_raises(RuntimeError, "Infinity must be a finite float") { calc2.add(Float::INFINITY, 2.0) }
      assert_raises(RuntimeError, "NaN must be a finite float") { calc_mod2.add(1.0, Float::NAN) }

      assert_in_delta 3.0, calc1.add(1.0, 2.0)
      assert_in_delta 3.0, calc_mod1.add(1.0, 2.0)
      assert_in_delta 3.0, calc2.add(1.0, 2.0)
      assert_in_delta 3.0, calc_mod2.add(1.0, 2.0)
    end

    test "that has the core proxy class methods" do
      assert_kind_of Core::Proxy::ClassMethods, CalcInterface::Proxy

      assert_kind_of Core::Proxy::ClassMethods, CalcInterfaceAlwaysEnabled::Proxy
    end
  end
end
