# frozen_string_literal: true

class Solid::Adapters::Configurable::Options
  MapOption = ->(key) { key.end_with?("=") ? key[0..-2].to_sym : key }
  MapValue = ->(value) { value.is_a?(::Proc) ? value.call : value }

  def initialize(**options)
    @options = options
  end

  def to_h
    @options.dup
  end

  def key?(name)
    @options.key?(name)
  end

  def [](name)
    @options[name].then(&MapValue)
  end

  def fetch(name, &block)
    @options.fetch(name, &block).then(&MapValue)
  end

  def method_missing(method_name, value = nil, &block)
    return fetch(method_name) { super } if !method_name.end_with?("=") && !block

    option_name = MapOption[method_name]

    @options[option_name] = block || value
  end

  def respond_to_missing?(method_name, include_private = false)
    (method_name.end_with?("=") || key?(method_name)) || super
  end

  def freeze
    @options.freeze

    super
  end
end
