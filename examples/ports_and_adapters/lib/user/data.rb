# frozen_string_literal: true

module User
  Data = ::Struct.new(:id, :name, :email, keyword_init: true)
end
