# frozen_string_literal: true

require "test_helper"

module Solid::Adapters
  class CoreProxyTest < Minitest::Test
    module Calc
      class Contract < Core::Proxy::Base
        FiniteNumber = lambda do |value|
          value.is_a?(::Numeric) or raise format("%p must be numeric", value)
          value.respond_to?(:finite?) && value.finite? or raise format("%p must be finite", value)
          value
        end

        CannotBeZero = lambda do |value|
          value.tap { _1.zero? and raise format("%p cannot be zero", _1) }
        end

        def add(a, b)
          FiniteNumber[a]
          FiniteNumber[b]

          FiniteNumber[object.add(a, b)]
        end

        def subtract(a, b)
          FiniteNumber[a]
          FiniteNumber[b]

          FiniteNumber[object.subtract(a, b)]
        end

        def divide(a, b)
          FiniteNumber[a]
          FiniteNumber[b].then(&CannotBeZero)

          FiniteNumber[object.divide(a, b)]
        end
      end

      class Operations
        def initialize(calc)
          @calc = Contract.new(calc)
        end

        def add(...)
          @calc.add(...)
        end

        def subtract(...)
          @calc.subtract(...)
        end

        def divide(...)
          @calc.divide(...)
        end
      end
    end

    module NamespaceA
      class CalcOperations
        def add(a, b)
          a + b
        end

        def subtract(a, b)
          a - b
        end

        def divide(a, b)
          a / b
        end
      end
    end

    module NamespaceB
      module CalcOperations
        def self.add(a, b)
          a + b
        end

        def self.subtract(a, b)
          a - b
        end

        def self.divide(a, b)
          a / b
        end
      end
    end

    test "dependency inversion" do
      calc1 = Calc::Operations.new(NamespaceA::CalcOperations.new)
      calc2 = Calc::Operations.new(NamespaceB::CalcOperations)

      assert_equal 3, calc1.add(1, 2)
      assert_equal 3, calc2.add(1, 2)

      assert_equal(-1, calc1.subtract(1, 2))
      assert_equal(-1, calc2.subtract(1, 2))

      assert_in_delta(0.5, calc1.divide(1.0, 2))
      assert_in_delta(0.5, calc2.divide(1.0, 2))
    end

    test "contract errors" do
      calc1 = Calc::Operations.new(NamespaceA::CalcOperations.new)
      calc2 = Calc::Operations.new(NamespaceB::CalcOperations)

      err1a = assert_raises(RuntimeError) { calc1.add(1, "2") }
      err2a = assert_raises(RuntimeError) { calc1.subtract("1", 2) }
      err3a = assert_raises(RuntimeError) { calc1.divide(1, 0) }

      err1b = assert_raises(RuntimeError) { calc2.add("1", 2) }
      err2b = assert_raises(RuntimeError) { calc2.subtract(1, "2") }
      err3b = assert_raises(RuntimeError) { calc2.divide("1", 0) }

      assert_equal('"2" must be numeric', err1a.message)
      assert_equal('"1" must be numeric', err2a.message)
      assert_equal("0 cannot be zero", err3a.message)

      assert_equal('"1" must be numeric', err1b.message)
      assert_equal('"2" must be numeric', err2b.message)
      assert_equal('"1" must be numeric', err3b.message)
    end

    test ".new" do
      object = ::Object.new

      instance = Core::Proxy::Base.new(object)

      assert_instance_of Core::Proxy::Base, instance
    end

    test ".new alias" do
      object = ::Object.new

      instance = Core::Proxy::Base[object]

      assert_instance_of Core::Proxy::Base, instance
    end

    test ".to_proc" do
      contracts = [NamespaceA::CalcOperations.new, NamespaceB::CalcOperations].map(&Calc::Contract)

      assert_equal [Calc::Contract, Calc::Contract], contracts.map(&:class)

      assert_equal 3, contracts[0].add(1, 2)
      assert_equal 3, contracts[1].add(1, 2)
    end

    test "#object" do
      object = ::Object.new

      instance = Core::Proxy::Base.new(object)

      assert_same object, instance.object
    end
  end
end
