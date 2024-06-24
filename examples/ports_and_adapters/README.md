<small>

> `MENU` [README](../../README.md) | [Examples](../README.md)

</small>

## 🔌 Ports and Adapters Example <!-- omit from toc -->

- [⚖️ What is the benefit of doing this?](#️-what-is-the-benefit-of-doing-this)
  - [How much to do this (create Ports and Adapters)?](#how-much-to-do-this-create-ports-and-adapters)
  - [Is it worth the overhead of contract checking at runtime?](#is-it-worth-the-overhead-of-contract-checking-at-runtime)
- [🏃‍♂️ How to run the application?](#️-how-to-run-the-application)

Ports and Adapters is an architectural pattern that separates the application's core logic (Ports) from external dependencies (Adapters).

This example shows how to implement a simple application using this pattern and the gem `solid-adapters`.

Let's start seeing the code structure:

```
├── Rakefile
├── config.rb
├── db
├── app
│  └── models
│     └── user
│        ├── record
│        │  └── repository.rb
│        └── record.rb
├── lib
│  └── user
│     ├── creation.rb
│     ├── data.rb
│     └── repository.rb
└── test
   └── user_test
      └── repository.rb
```

The files and directories are organized as follows:

- `Rakefile` runs the application.
- `config.rb` file contains the configuration of the application.
- `db` directory contains the database. It is not part of the application, but it is used by the application.
- `app` directory contains "Rails" components.
- `lib` directory contains the core business logic.
- `test` directory contains the tests.

The application is a simple "user management system". It unique core functionality is to create users.

Now we understand the code structure, let's see the how the pattern is implemented.

### The Port

In this application, there is only one business process: `User::Creation` (see `lib/user/creation.rb`), which relies on the `User::Repository` (see `lib/user/repository.rb`) to persist the user.

The `User::Repository` is an example of **port**, because it is an interface/contract that defines how the core business logic will persist user records.

```ruby
module User::Repository
  include Solid::Adapters::Interface

  module Methods
    def create(name:, email:)
      name => String
      email => String

      super.tap { _1 => ::User::Data[id: Integer, name: String, email: String] }
    end
  end
end
```

### The Adapters

The `User::Repository` is implemented by two adapters:

- `User::Record::Repository` (see `app/models/user/record/repository.rb`) is an adapter that persists user records in the database (through the `User::Record`, that is an `ActiveRecord` model).

- `UserTest::Repository` (see `test/user_test/repository.rb`) is an adapter that persists user records in memory (through the `UserTest::Data`, that is a simple in-memory data structure).

## ⚖️ What is the benefit of doing this?

The benefit of doing this is that the core business logic is decoupled from the external dependencies, which makes it easier to test and promote changes in the code.

For example, if we need to change the persistence layer (start to send the data to a REST API or a Redis DB), we just need to implement a new adapter and make the business processes (`User::Creation`) use it.

### How much to do this (create Ports and Adapters)?

Use this pattern when there is a real need to decouple the core business logic from external dependencies.

You can start with a simple implementation (without Ports and Adapters) and refactor it to use this pattern when the need arises.

### Is it worth the overhead of contract checking at runtime?

You can eliminate the overhead by disabling the `Solid::Adapters::Interface`, which is enabled by default.

When it is disabled, the `Solid::Adapters::Interface` won't prepend the interface methods module to the adapter, which means that the adapter won't be checked against the interface.

To disable it, set the configuration to false:

```ruby
Solid::Adapters.configuration do |config|
  config.interface_enabled = false
end
```

## 🏃‍♂️ How to run the application?

In the same directory as this `README`, run:

```bash
rake # or rake SOLID_ADAPTERS_ENABLED=enabled

# or

rake SOLID_ADAPTERS_ENABLED=false
```

**Proxy enabled**

```bash
rake # or rake SOLID_ADAPTERS_ENABLED=enabled

# Output sample:
#
# --  Valid input  --
#
# Created user: #<struct User::Data id=1, name="Jane", email="jane@foo.com">
# Created user: #<struct User::Data id=1, name="John", email="john@bar.com">
#
# --  Invalid input  --
#
# rake aborted!
# NoMatchingPatternError: nil: String === nil does not return true (NoMatchingPatternError)
# /.../lib/user/repository.rb:9:in `create'
# /.../lib/user/creation.rb:12:in `call'
# /.../Rakefile:36:in `block in <top (required)>'
```

**Proxy disabled**

```bash
rake SOLID_ADAPTERS_ENABLED=false

# Output sample:
#
# --  Valid input  --
#
# Created user: #<struct User::Data id=1, name="Jane", email="jane@foo.com">
# Created user: #<struct User::Data id=1, name="John", email="john@bar.com">
#
# --  Invalid input  --
#
# Created user: #<struct User::Data id=2, name="Jane", email=nil>
# Created user: #<struct User::Data id=3, name="", email=nil>
```
