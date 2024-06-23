# frozen_string_literal: true

module PaymentGateways
  class Adapters::CircleUp
    attr_reader :client

    def initialize
      @client = ::CircleUp::Client.new
    end

    def charge_credit_card(params)
      params => { amount:, details: }

      response = client.charge_cc(amount, details)

      Response.new(response.ok?)
    end
  end
end
