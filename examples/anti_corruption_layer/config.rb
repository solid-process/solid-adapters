# frozen_string_literal: true

require "bundler/inline"

$LOAD_PATH.unshift(__dir__)

gemfile do
  source "https://rubygems.org"

  gem "solid-result", "~> 2.0"
  gem "solid-adapters", path: "../../"
end

require "vendor/pay_friend/client"
require "vendor/circle_up/client"

require "lib/payment_gateways"

require "app/models/payment/charge_credit_card"
