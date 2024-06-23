# frozen_string_literal: true

require "simplecov"

SimpleCov.start do
  enable_coverage :branch

  add_filter "/test/"
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "solid/adapters"

Dir[File.expand_path("support/**/*.rb", __dir__)]
  .sort
  .reject { |file| file.match?((RUBY_VERSION >= "3.0.0") ? /2_7/ : /gte_3/) }
  .each { |file| require file }

require "minitest/autorun"

require "mocha/minitest"

class Minitest::Test
  # Implementation based on:
  # https://github.com/rails/rails/blob/ac717d6/activesupport/lib/active_support/testing/declarative.rb
  def self.test(name, &block)
    test_name = :"test_#{name.gsub(/\s+/, "_")}"

    method_defined?(test_name) and raise "#{test_name} is already defined in #{self}"

    if block
      define_method(test_name, &block)
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end
  end
end
