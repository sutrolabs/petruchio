# frozen_string_literal: true

require "test_helper"
require "redis"

class TestPetruchio < Minitest::Test

  def setup
    @redis = Redis.new
  end

  def test_that_it_has_a_version_number
    refute_nil ::Petruchio::VERSION
  end

  def test_ring_initializes_with_a_large_amount_of_elements
    ring_name = "this_is_a_unique_ring_name"
    size = 200_000
    initial_item = 0.0

    # Make sure our test key does not exist so that the initialize lua script runs
    @redis.del(ring_name)

    Petruchio::Ring.new(@redis, ring_name, size, initial_item)

    assert_equal size, @redis.llen(ring_name)
  end

  def test_ring_can_resize_to_a_large_amount_of_elements
    ring_name = "this_is_a_another_unique_ring_name"
    initial_size = 10
    initial_item = 0.0

    @redis.del(ring_name)

    ring = Petruchio::Ring.new(@redis, ring_name, initial_size, initial_item)

    new_size = 200_000
    ring.resize(new_size)

    assert_equal new_size, @redis.llen(ring_name)
  end

  def test_ring_can_resize_to_a_smaller_amount_of_elements
    ring_name = "test_key_to_resize_from_100_to_10"
    initial_size = 100
    initial_item = 0.0

    @redis.del(ring_name)

    ring = Petruchio::Ring.new(@redis, ring_name, initial_size, initial_item)

    new_size = 10
    ring.resize(new_size)

    assert_equal new_size, @redis.llen(ring_name)
  end
end
