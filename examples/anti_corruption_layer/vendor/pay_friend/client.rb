# frozen_string_literal: true

module PayFriend
  class Client
    APIResponse = ::Struct.new(:status)

    def charge(amount:, payment_method:, payment_data:)
      APIResponse.new('success')
    end
  end
end
