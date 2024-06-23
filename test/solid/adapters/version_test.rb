# frozen_string_literal: true

require "test_helper"

class Solid::Adapters::VersionTest < Minitest::Test
  test "that it has a version number" do
    refute_nil ::Solid::Adapters::VERSION
  end
end
