# frozen_string_literal: true

module UserTest
  class Repository
    include ::User::Repository

    attr_reader :records

    def initialize
      @records = []
    end

    def create(name:, email:)
      id = @records.size + 1

      @records[id] = { id:, name:, email: }

      ::User::Data.new(id:, name:, email:)
    end
  end
end
