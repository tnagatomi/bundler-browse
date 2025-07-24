# frozen_string_literal: true

require "test_helper"

class Bundler::TestBrowse < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Bundler::Browse::VERSION
  end
end
