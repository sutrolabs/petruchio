# Petruchio - a Redis ring buffer in Ruby and Lua

> We will have rings, and things, and fine array.

**-Petruchio** (The Taming of the Shrew)

## What?

Need a Redis ring buffer? Here's a simple one in Ruby and Lua.

Supports resizing too if you later need to grow or shrink the buffer.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add petruchio

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install petruchio

## Usage

There's a bunch of reasons you might want to use a ring buffer. For example, you might need one to back a rate limiter. Give it your Redis instance, a name for the buffer, buffer size, and a default value each entry in the buffer is initialized with:

```ruby
@ring = Petruchio::Ring.new(redis_instance, 'request_limiter', 10, 0.0)
```

Once you have a ring, pop will remove the oldest things from the buffer:

```ruby
previous_request_time = @ring.pop.to_f
```

push will add the newest things:

```ruby
@ring.push(future_request_time.to_f)
```

(If you need a lock around pushing and popping stay tuned and [watch our org](https://github.com/sutrolabs).)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

Feedback
--------
[Source code available on Github](https://github.com/sutrolabs/petruchio). Feedback and pull requests are greatly appreciated. Let us know if we can improve this.

From
-----------
:wave: The folks at [Census](http://getcensus.com) originally put this together. Have data? We'll sync your data warehouse with your CRM and the customer success apps critical to your team. Interested in joining the team? **[Come work with us](https://www.getcensus.com/careers)**.