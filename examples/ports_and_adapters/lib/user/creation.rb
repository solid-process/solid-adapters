# frozen_string_literal: true

module User
  class Creation
    def initialize(repository:)
      repository => Repository

      @repository = repository
    end

    def call(name:, email:)
      user_data = @repository.create(name:, email:)

      puts "Created user: #{user_data.inspect}"

      user_data
    end
  end
end
