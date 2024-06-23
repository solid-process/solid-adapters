# frozen_string_literal: true

module CircleUp
  class Client
    Resp = ::Struct.new(:ok?)

    def charge_cc(_amount, _credit_card_data)
      Resp.new(true)
    end
  end
end
