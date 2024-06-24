<p align="center">
  <h1 align="center" id="-solidadapters">🧩 Solid::Adapters</h1>
  <p align="center"><i>Write interface contracts using pure Ruby.</i></p>
  <p align="center">
    <a href="https://codeclimate.com/github/solid-process/solid-adapters/maintainability"><img src="https://api.codeclimate.com/v1/badges/b94564ac2686bc8d5feb/maintainability" /></a>
    <a href="https://codeclimate.com/github/solid-process/solid-adapters/test_coverage"><img src="https://api.codeclimate.com/v1/badges/b94564ac2686bc8d5feb/test_coverage" /></a>
    <img src="https://img.shields.io/badge/Ruby%20%3E%3D%202.7%2C%20%3C%3D%20Head-ruby.svg?colorA=444&colorB=333" alt="Ruby">
  </p>
</p>

## 📚 Table of Contents <!-- omit from toc -->

- [Supported Ruby](#supported-ruby)
- [Examples](#examples)
- [Installation](#installation)
- [Usage](#usage)
  - [`Solid::Adapters::Interface`](#solidadaptersinterface)
    - [Dynamic proxies](#dynamic-proxies)
  - [`Solid::Adapters::Proxy`](#solidadaptersproxy)
- [Configuration](#configuration)
  - [Non-toggleable features](#non-toggleable-features)
  - [Solid::Adapters.configuration(freeze: false)](#solidadaptersconfigurationfreeze-false)
  - [Solid::Adapters.config](#solidadaptersconfig)
  - [`Solid::Adapters::Interface` versus `Solid::Adapters::Proxy`](#solidadaptersinterface-versus-solidadaptersproxy)
  - [`Solid::Adapters::Configurable`](#solidadaptersconfigurable)
    - [Configuration](#configuration-1)
- [About](#about)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Supported Ruby

This library is tested against:

Coverage | 2.7 | 3.0 | 3.1 | 3.2 | 3.3 | Head
---- | --- | --- | --- | --- | --- | ---
100%  | ✅  | ✅  | ✅  | ✅  | ✅  | ✅

## Examples

Check the [examples](examples) directory to see different applications of `solid-adapters`.

> **Attention:** Each example has its own **README** with more details.

1. [Ports and Adapters](examples/ports_and_adapters) - Implements the Ports and Adapters pattern. It uses [**`Solid::Adapters::Interface`**](#solidadaptersinterface) to provide an interface from the application's core to other layers.

2. [Anti-Corruption Layer](examples/anti_corruption_layer) - Implements the Anti-Corruption Layer pattern. It uses the [**`Solid::Adapters::Proxy`**](#solidadapterstproxy) to define an interface for a set of adapters, which will translate an external interface (`vendors`) to the application's core interface.

3. [Solid::Rails::App](https://github.com/solid-process/solid-rails-app/tree/solid-process-4?tab=readme-ov-file#-solid-rails-app-) - A Rails application (Web and REST API) made with  `solid-adapters` + [`solid-process`](https://github.com/solid-process/solid-process) that uses the Ports and Adapters (Hexagonal) architectural pattern to decouple the application's core from the framework.

<p align="right"><a href="#-solidadapters">⬆️ &nbsp;back to top</a></p>

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add solid-adapters

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install solid-adapters

And require it in your code:

    require 'solid/adapters'

<p align="right"><a href="#-solidadapters">⬆️ &nbsp;back to top</a></p>

## Usage

### `Solid::Adapters::Interface`

This feature allows the creation of a module that will be used as an interface.

It will check if the class that includes it or the object that extends it implements all the expected methods.

```ruby
module User::Repository
  include ::Solid::Adapters::Interface

  module Methods
    def create(name:, email:)
      name => String
      email => String

      super.tap { _1 => ::User::Data[id: Integer, name: String, email: String] }
    end
  end
end
```

Let's break down the example above.

1. The `User::Repository` module includes `Solid::Adapters::Interface`.
2. Defines the `Methods` module. It is mandatory, as these will be the methods to be implemented.
3. The `create` method is defined inside the `Method`s' module.
   1. This method receives two arguments: `name` and `email`.
   2. The arguments are checked using the `=>` pattern matching operator.
   3. `super` is called to invoke the `create` method of the superclass. Which will be the class/object that includes/extends the `User::Repository` module.
   4. The `super` output is checked using pattern matching under the `tap` method.

Now, let's see how to use it in a class.

```ruby
class User::Record::Repository
  include User::Repository

  def create(name:, email:)
    record = Record.create(name:, email:)

    ::User::Data.new(id: record.id, name: record.name, email: record.email)
  end
end
```

And how to use it in a module with singleton methods.

```ruby
module User::Record::Repository
  extend User::Repository

  def self.create(name:, email:)
    record = Record.create(name:, email:)

    ::User::Data.new(id: record.id, name: record.name, email: record.email)
  end
end
```

**What happend when an interface module is included/extended?**

1. An instance of the class will be a `User::Repository`.
2. The module, class, object, that extended the interface will be a `User::Repository`.

```ruby
class User::Record::Repository
  include User::Repository
end

module UserTest::RepositoryInMemory
  extend User::Repository
  # ...
end

User::Record::Repository.new.is_a?(User::Repository) # true

UserTest::RepositoryInMemory.is_a?(User::Repository) # true
```

**Why this is useful?**

You can use `=>` pattern matching or `is_a?` to ensure that the class/object implements the expected methods as it includes/extends the interface.

```ruby
class User::Creation
  def initialize(repository)
    repository => User::Repository

    @repository = repository
  end

  # ...
end
```

> Access the [**Ports and Adapters example**](examples/ports_and_adapters) to see, test, and run something that uses the `Solid::Adapters::Interface`

<p align="right"><a href="#-solidadapters">⬆️ &nbsp;back to top</a></p>

#### Dynamic proxies

The `Solid::Adapters::Interface` can be used to create dynamic proxies. To do this, you must use the `.[]` method to wrap an object in a proxy that will check if the object implements the interface methods.

The advantage of dynamic proxies is that you can create a proxy for any object. Therefore, you don't need to include/extend the interface module to perform the checkings.

```ruby
class User::Repository
  include ::Solid::Adapters::Interface

  module Methods
    def create(name:, email:)
      name => String
      email => String

      super.tap { _1 => ::User::Data[id: Integer, name: String, email: String] }
    end
  end
end

## Real object example

class User::Record::Repository
  def create(name:, email:)
    ::User::Data.new(id: 1, name: name, email: email)
  end
end

repository = User::Repository[User::Record::Repository.new]

## Mock example

mock_repository = double

allow(mock_repository)
  .to receive(:create)
  .with(name: 'John', email: 'john@email.com')
  .and_return(::User::Data.new(id: 1, name: 'John', email: 'john@email.com'))

repository = User::Repository[mock_repository]
```

<p align="right"><a href="#-solidadapters">⬆️ &nbsp;back to top</a></p>

### `Solid::Adapters::Proxy`

This feature allows the creation of a class that will be used as a proxy for another objects.

The idea is to define an interface for the object that will be proxied.

Let's implement the example from the [previous section](#solidadaptersinterface) using a proxy.

```ruby
class User::Repository < Solid::Adapters::Proxy
  def create(name:, email:)
    name => String
    email => String

    object.create(name:, email:).tap do
      _1 => ::User::Data[id: Integer, name: String, email: String]
    end
  end
end
```

**How to use it?**

Inside the proxy you will use `object` to access the proxied object. This means the proxy must be initialized with an object. And the object must implement the methods defined in the proxy.

```ruby
class User::Record::Repository
  # ...
end

module UserTest::RepositoryInMemory
  extend self
  # ...
end

# The proxy must be initialized with an object that implements the expected methods

memory_repository = User::Repository.new(UserTest::RepositoryInMemory)

record_repository = User::Repository.new(User::Record::Repository.new)
```

> Access the [**Anti-Corruption Layer**](examples/anti_corruption_layer) to see, test, and run something that uses the `Solid::Adapters::Proxy`

<p align="right"><a href="#-solidadapters">⬆️ &nbsp;back to top</a></p>

## Configuration

By default, the `Solid::Adapters` enables all its features. You can disable them by setting the configuration.

```ruby
Solid::Adapters.configuration do |config|
  dev_or_test = ::Rails.env.local?

  config.proxy_enabled = dev_or_test
  config.interface_enabled = dev_or_test
end

# PS: You can use .configure is an alias for .configuration
```

In the example above, the `Solid::Adapters::Proxy`, `Solid::Adapters::Interface` will be disabled in production.

<p align="right"><a href="#-solidadapters">⬆️ &nbsp;back to top</a></p>

###  Non-toggleable features

The following variants are always enabled. You cannot disable them through the configuration.

#### `Solid::Adapters::Proxy::AlwaysEnabled` <!-- omit from toc -->

```ruby
class User::Repository
  include ::Solid::Adapters::Interface::AlwaysEnabled

  module Methods
    # ...
  end
end
```

#### `Solid::Adapters::Interface::AlwaysEnabled` <!-- omit from toc -->

```ruby
class User::Repository < Solid::Adapters::Proxy::AlwaysEnabled
  # ...
end
```

<p align="right"><a href="#-solidadapters">⬆️ &nbsp;back to top</a></p>

### Solid::Adapters.configuration(freeze: false)

By default, the configuration is frozen after the block is executed. This means you cannot change the configuration after the application boot. If you need to change the configuration after the application boot, you can set the `freeze` option to `false`.

```ruby
Solid::Adapters.configuration(freeze: false) do |config|
  config.proxy_enabled = false
  config.interface_enabled = ::Rails.env.local?
end
```

<p align="right"><a href="#-solidadapters">⬆️ &nbsp;back to top</a></p>

### Solid::Adapters.config

You can access or change (if the configuration is not frozen) the configuration by using the `Solid::Adapters.config` method.

<p align="right"><a href="#-solidadapters">⬆️ &nbsp;back to top</a></p>

### `Solid::Adapters::Interface` versus `Solid::Adapters::Proxy`

The main difference between the interface and the proxy is when the settings take effect.

`Solid::Adapters::Interface` modules are applied with the application boot. So, you must ensure that the `Solid::Adapters.configuration` runs before loading the code. On the other hand, proxies dynamically check the configuration every time a proxy instance is generated, allowing for the possibility of turning `Solid::Adapters::Proxy` post-application boot.

I recommend using interfaces, as they can be included/extended directly and because they dynamically produce proxies. In other words, they are more versatile. But please remember you have different feature toggles in the configuration for using both adapters based on your application needs.

<p align="right"><a href="#-solidadapters">⬆️ &nbsp;back to top</a></p>

### `Solid::Adapters::Configurable`

The `Solid::Adapters::Configurable` module can be included in a class to provide a configuration block. This is useful when you want to inject/define dependencies into a namespace dynamically.

First you need to include the module in the class. And define the configurations that you want to expose.

```ruby
module User::Adapters
  extend Solid::Adapters::Configurable

  config.repository = nil
end
```

Then you can use the `configure` method to set the configurations. Lets use a Rails initializer to set the repository.

```ruby
# config/initializers/user_adapters.rb

User::Adapters.configuration do |config|
  config.repository = User::Record::Repository.new
end
```

So you can access the repository in some place like this:

```ruby
class User::Creation
  def initialize
    @repository = User::Adapters.config.repository
  end

  def create(name:, email:)
    @repository.create(name: name, email: email)
  end
end
```

<p align="right"><a href="#-solidadapters">⬆️ &nbsp;back to top</a></p>

#### Configuration

First, the `Solid::Adapters.configuration` does not affect the `Solid::Adapters::Configurable` configurations. This means you can use both features together.

Second, as the `Solid::Adapters.configuration` method, the `Solid::Adapters::Configurable` configurations are frozen by default. You can change this behavior by setting the `freeze` option to `false`.

```ruby
# config/initializers/user_adapters.rb

User::Adapters.configuration(freeze: false) do |config|
  config.repository = User::Record::Repository.new
end

# PS: You can use .configure is an alias for .configuration
```

> Access the [Solid::Rails::App](https://github.com/solid-process/solid-rails-app/tree/solid-process-4?tab=readme-ov-file#-solid-rails-app-) versions 3 and 4 to see, test, and run something that uses the `Solid::Adapters::Configurable`.

<p align="right"><a href="#-solidadapters">⬆️ &nbsp;back to top</a></p>

## About

[Rodrigo Serradura](https://github.com/serradura) created this project. He is the Solid Process creator and has already made similar gems like the [u-case](https://github.com/serradura/u-case) and [kind](https://github.com/serradura/kind/blob/main/lib/kind/result.rb). This gem can be used independently, but it also contains essential features that facilitate the adoption of Solid Process (the method) in code.

<p align="right"><a href="#-solidadapters">⬆️ &nbsp;back to top</a></p>

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/solid-process/solid-adapters. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/solid-process/solid-adapters/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Solid::Adapters project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/solid-adapters/blob/master/CODE_OF_CONDUCT.md).
