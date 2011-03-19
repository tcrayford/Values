Values is a tiny library for creating value objects in ruby.
These mostly look like classes created using Struct, but fix two problems with those:

- Struct constructors can take less than the default number of arguments and set other fields as nil:
    Point = Struct.new(:x,:y)
    Point.new(1)
    => #<struct Point x=1, y=nil>

- Structs are also mutable:
    Point = Struct.new(:x,:y)
    p = Point.new(1,2)
    p.x = 2
    p.x
    => 2

Values fixes both of these:
    Point = Value.new(:x, :y)
    Point.new(1)
    => SOME EXCEPTION

    p = Point.new(1,2)
    p.x = 1
    => SOME EXCEPTION
