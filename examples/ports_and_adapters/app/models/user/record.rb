# frozen_string_literal: true

module User
  class Record < ActiveRecord::Base
    self.table_name = 'users'
  end
end
