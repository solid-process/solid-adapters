# frozen_string_literal: true

module PaymentGateways
  require_relative 'payment_gateways/contract'
  require_relative 'payment_gateways/response'

  module Adapters
    require_relative 'payment_gateways/adapters/circle_up'
    require_relative 'payment_gateways/adapters/pay_friend'
  end
end
