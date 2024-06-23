# frozen_string_literal: true

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
