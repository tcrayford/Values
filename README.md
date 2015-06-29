[![Gem Version](https://img.shields.io/gem/v/values.svg)](https://rubygems.org/gems/values/)
[![Gem Downloads](https://img.shields.io/gem/dt/values.svg)](https://rubygems.org/gems/values/)
[![CI Build Status](https://img.shields.io/travis/tcrayford/Values.svg)](https://travis-ci.org/tcrayford/Values)
[![Code Coverage](https://img.shields.io/codecov/c/github/tcrayford/Values.svg)](https://codecov.io/github/tcrayford/Values)

Values is a tiny library for creating value objects in ruby.
These mostly look like classes created using Struct, but fix two problems with those:

Struct constructors can take less than the default number of arguments and set other fields as nil:

```ruby
Point = Struct.new(:x, :y)
Point.new(1)
# => #<struct Point x=1, y=nil>
```

Structs are also mutable:

```ruby
Point = Struct.new(:x, :y)
p = Point.new(1, 2)
p.x = 2
p.x
# => 2
```

Values fixes both of these:

```ruby
Point = Value.new(:x, :y)
Point.new(1)
# => ArgumentError: wrong number of arguments, 1 for 2
# from /Users/tcrayford/Projects/ruby/values/lib/values.rb:7:in `block (2 levels) in new
# from (irb):5:in new
# from (irb):5
# from /usr/local/bin/irb:12:in `<main>

p = Point.new(1, 2)
p.x = 1
# => NoMethodError: undefined method x= for #<Point:0x00000100943788 @x=0, @y=1>
# from (irb):6
# from /usr/local/bin/irb:12:in <main>
```

Values also provides an alternative constructor which takes a hash:

```ruby
p = Point.with(x: 3, y: 4)
p.x
# => 3
```

Values can copy and replace fields using a hash:

```ruby
p = Point.with(x: 1, y: -1)
q = p.with(y: 2)
# => #<Point x=1, y=2>
```

Value classes can be converted to a hash, like OpenStruct:

```ruby
Point.with(x: 1, y: -1).to_h
# => {:x=>1, :y=>-1}
```

Values also supports customization of value classes inheriting from `Value.new`:

```ruby
class Point < Value.new(:x, :y)
  def to_s
    "<Point at (#{x}, #{y})>"
  end
end

p = Point.new(1, 2)
p.to_s
# => "<Point at (1, 2)>"
```

Values does NOT have all the features of Struct (nor is it meant to).
