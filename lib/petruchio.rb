# frozen_string_literal: true

require_relative "petruchio/version"

module Petruchio
  class Ring

    INIT_LUA_SCRIPT = <<~LUA
      local key = KEYS[1]
      local size = tonumber(ARGV[1])
      local value = ARGV[2]

      if redis.call('EXISTS', key) == 0 then
        for i=1,size do
          redis.call('RPUSH', key, value)
        end
      end
    LUA

    RESIZE_LUA_SCRIPT = <<~LUA
      local key = KEYS[1]
      local size = redis.call("llen", key)
      local new_size = tonumber(ARGV[1])
      local value = ARGV[2]

      if size > new_size then
        redis.call('LTRIM', key, (size - new_size), (size - 1))
      elseif size < new_size then
        for i = 1, (new_size - size) do
          redis.call('RPUSH', key, value)
        end
      end

      return redis.call('LLEN', key)
    LUA

    def initialize(redis, ring_name, size, initial_item)
      @redis = redis
      @ring_name = ring_name
      @initial_item = initial_item

      @redis.eval(INIT_LUA_SCRIPT, [@ring_name], [size, @initial_item])
    end

    def resize(new_size)
      # returns the new size
      @redis.eval RESIZE_LUA_SCRIPT, [@ring_name], [new_size, @initial_item]
    end

    def pop
      @redis.lpop @ring_name
    end

    def push(item)
      @redis.rpush @ring_name, item
    end

    def push_pop(item)
      popped, *rest =
        T.let(
          @redis.multi do |transaction|
            transaction.lpop @ring_name
            transaction.rpush @ring_name, item
          end,
          [String, T.untyped]
        )

      popped
    end

    def read
      @redis.lrange(@ring_name, 0, -1)
    end
  end
end
