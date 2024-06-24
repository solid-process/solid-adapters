<small>

> `MENU` [README](../../README.md) | [Examples](../README.md)

</small>

## 🛡️ Anti-Corruption Layer Example <!-- omit from toc -->

- [The ACL](#the-acl)
  - [🤔 How does it work?](#-how-does-it-work)
    - [📜 The Contract](#-the-contract)
    - [🔄 The Adapters](#-the-adapters)
- [⚖️ What is the benefit of doing this?](#️-what-is-the-benefit-of-doing-this)
  - [How much to do this (create ACL)?](#how-much-to-do-this-create-acl)
  - [Is it worth the overhead of contract checking at runtime?](#is-it-worth-the-overhead-of-contract-checking-at-runtime)
- [🏃‍♂️ How to run the application?](#️-how-to-run-the-application)

The **Anti-Corruption Layer**, or ACL, is a pattern that isolates and protects a system from legacy or dependencies out of its control. It acts as a mediator, translating and adapting data between different components, ensuring they communicate without corrupting each other's data or logic.

To illustrate this pattern, let's see an example of an application that uses  third-party API to charge a credit card.

Let's start seeing the code structure of this example:

```
├── Rakefile
├── config.rb
├── app
│  └── models
│     └── payment
│        └── charge_credit_card.rb
├── lib
│  ├── payment_gateways
│  │  ├── adapters
│  │  │  ├── circle_up.rb
│  │  │  └── pay_friend.rb
│  │  ├── contract.rb
│  │  └── response.rb
│  └── payment_gateways.rb
└── vendor
   ├── circle_up
   │  └── client.rb
   └── pay_friend
      └── client.rb
```

The files and directories are organized as follows:

- `Rakefile` runs the application.
- `config.rb` file contains the configurations.
- `app` directory contains the domain model where the business process to charge a credit card is implemented.
- `lib` directory contains the payment gateways contract and adapters.
- `vendor` directory contains the third-party API clients.

## The ACL

The ACL is implemented in the `PaymentGateways` module (see `lib/payment_gateways.rb`). It translates the third-party APIs (see `vendor`) into something known by the application's domain model. Through this module, the application can charge a credit card without knowing the details/internals of the vendors.

### 🤔 How does it work?

The `PaymentGateways::ChargeCreditCard` class (see `app/models/payment/charge_credit_card.rb`) uses`PaymentGateways::Contract` to ensure the `payment_gateway` object implements the required and known interface (input and output) to charge a credit card.

```ruby
module Payment
  class ChargeCreditCard
    include ::Solid::Output.mixin(config: { addon: { continue: true } })

    attr_reader :payment_gateway

    def initialize(payment_gateway)
      @payment_gateway = ::PaymentGateways::Contract.new(payment_gateway)
    end

    def call(amount:, details: {})
      Given(amount:)
        .and_then(:validate_amount)
        .and_then(:charge_credit_card, details:)
        .and_expose(:payment_charged, %i[payment_id])
    end

    private

    def validate_amount(amount:)
      return Continue() if amount.is_a?(::Numeric) && amount.positive?

      Failure(:invalid_amount, erros: ['amount must be positive'])
    end

    def charge_credit_card(amount:, details:)
      response = payment_gateway.charge_credit_card(amount:, details:)

      Continue(payment_id: ::SecureRandom.uuid) if response.success?
    end
  end
end
```

#### 📜 The Contract

The `PaymentGateways::Contract` defines the interface of the payment gateways. It is implemented by the `PaymentGateways::Adapters::CircleUp` and `PaymentGateways::Adapters::PayFriend` adapters.

```ruby
module PaymentGateways
  class Contract < ::Solid::Adapters::Proxy
    def charge_credit_card(params)
      params => { amount: Numeric, details: Hash }

      outcome = object.charge_credit_card(params)

      outcome => Response[true | false]

      outcome
    end
  end
end
```

In this case, the contract will ensure the input by using the `=>` pattern-matching operator, which will raise an exception if it does not match the expected types. After that, it calls the adapter's `charge_credit_card` method and ensures the output is a `PaymentGateways::Response` by using the `=>` operator again.

The response (see `lib/payment_gateways/response.rb`) will ensure the ACL, as it is the object known/exposed to the application.

```ruby
module PaymentGateways
  Response = ::Struct.new(:success?)
end
```

#### 🔄 The Adapters

Let's see the payment gateways adapters:

`lib/payment_gateways/adapters/circle_up.rb`

```ruby
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
```

`lib/payment_gateways/adapters/pay_friend.rb`

```ruby
module PaymentGateways
  class Adapters::PayFriend
    attr_reader :client

    def initialize
      @client = ::PayFriend::Client.new
    end

    def charge_credit_card(params)
      params => { amount:, details: }

      response = client.charge(amount:, payment_data: details, payment_method: 'credit_card')

      Response.new(response.status == 'success')
    end
  end
end
```

You can see that each third-party API has its way of charging a credit card, so the adapters are responsible for translating the input/output from the third-party APIs to the output known by the application (the `PaymentGateways::Response`).

## ⚖️ What is the benefit of doing this?

The benefit of doing this is that the core business logic is decoupled from the legacy/external dependencies, which makes it easier to test and promote changes in the code.

Using this example, if the third-party APIs change, we just need to implement a new adapter and make the business processes (`Payment::ChargeCreditCard`) use it. The business processes will not be affected as it is protected by the ACL.

### How much to do this (create ACL)?

Use this pattern when there is a real need to decouple the core business logic from external dependencies.

You can start with a simple implementation (without ACL) and refactor it to use this pattern when the need arises.

### Is it worth the overhead of contract checking at runtime?

You can eliminate the overhead by disabling the `Solid::Adapters::Proxy` class, which is a proxy that forwards all the method calls to the object it wraps.

When it is disabled, the `Solid::Adapters::Proxy.new` returns the given object so that the method calls are made directly to it.

To disable it, set the configuration to false:

```ruby
Solid::Adapters.configuration do |config|
  config.proxy_enabled = false
end
```

## 🏃‍♂️ How to run the application?

In the same directory as this `README`, run:

```bash
rake

# --  CircleUp  --
#
# #<Solid::Output::Success type=:payment_charged value={:payment_id=>"2df767d0-af83-4657-b28d-6605044ffe2c"}>
#
# --  PayFriend  --
#
# #<Solid::Output::Success type=:payment_charged value={:payment_id=>"dd2af4cc-8484-4f6a-bc35-f7a5e6917ecc"}>
```
