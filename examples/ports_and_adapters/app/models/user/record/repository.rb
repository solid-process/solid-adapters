# frozen_string_literal: true

module User
  module Record::Repository
    extend ::User::Repository

    def self.create(name:, email:)
      record = Record.create!(name:, email:)

      ::User::Data.new(id: record.id, name: record.name, email: record.email)
    end
  end
end
