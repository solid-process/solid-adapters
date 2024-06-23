# frozen_string_literal: true

require "test_helper"

class Solid::Adapters::InterfaceTest < Minitest::Test
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

  module Calc
    module Add
      def add(a, b)
        a + b
      end
    end

    class Base
      include Add
    end
  end

  class Calc1a < Calc::Base
    include CalcInterface
  end

  module Calc1b
    extend CalcInterface

    def self.add(a, b)
      a + b
    end
  end

  class Calc2a
    include CalcInterfaceAlwaysEnabled

    def add(a, b)
      a + b
    end
  end

  module Calc2b
    extend CalcInterfaceAlwaysEnabled
    extend Calc::Add
  end

  module Calc2c
    extend Calc::Add
    extend CalcInterfaceAlwaysEnabled
  end

  test "interfaces" do
    assert_kind_of(CalcInterface, Calc1a.new)
    assert_kind_of(CalcInterface, Calc1b)

    assert_kind_of(CalcInterfaceAlwaysEnabled, Calc2a.new)
    assert_kind_of(CalcInterfaceAlwaysEnabled, Calc2b)
    assert_kind_of(CalcInterfaceAlwaysEnabled, Calc2c)

    assert_raises(RuntimeError, "a and b must be floats") { Calc1a.new.add(1, 2.0) }
    assert_raises(RuntimeError, "a and b must be floats") { Calc1b.add(1.0, 2) }
    assert_raises(RuntimeError, "a and b must be floats") { Calc2a.new.add(1, 2.0) }
    assert_raises(RuntimeError, "a and b must be floats") { Calc2b.add(1.0, 2) }
    assert_raises(RuntimeError, "a and b must be floats") { Calc2c.add(1.0, 2) }

    assert_raises(RuntimeError, "NaN must be a finite float") { Calc1a.new.add(Float::NAN, 2.0) }
    assert_raises(RuntimeError, "Infinity and b must be floats") { Calc1b.add(1.0, Float::INFINITY) }
    assert_raises(RuntimeError, "Infinity must be a finite float") { Calc2a.new.add(Float::INFINITY, 2.0) }
    assert_raises(RuntimeError, "NaN must be a finite float") { Calc2b.add(1.0, Float::NAN) }
    assert_raises(RuntimeError, "NaN must be a finite float") { Calc2c.add(Float::INFINITY, Float::NAN) }

    assert_in_delta 3.0, Calc1a.new.add(1.0, 2.0)
    assert_in_delta 3.0, Calc1b.add(1.0, 2.0)
    assert_in_delta 3.0, Calc2a.new.add(1.0, 2.0)
    assert_in_delta 3.0, Calc2b.add(1.0, 2.0)
    assert_in_delta 3.0, Calc2c.add(1.0, 2.0)
  end
end
