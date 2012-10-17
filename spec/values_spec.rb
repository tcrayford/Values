require File.expand_path(File.dirname(__FILE__) + '/../lib/values')
describe 'values' do
  it 'stores a single field' do
    Cell = Value.new(:alive)
    c = Cell.new(true)
    c.alive.should == true
  end

  Point = Value.new(:x, :y)
  it 'stores multiple values' do
    p = Point.new(0,1)
    p.x.should == 0
    p.y.should == 1
  end

  it 'can be initialized with []' do
    p = Point[0,1]
    p.should be_a Point
    p.should == Point.new(0,1)
  end

  it 'raises argument errors if not given the right number of arguments' do
    lambda { Point.new }.should raise_error(ArgumentError, 'wrong number of arguments, 0 for 2')
  end

  it 'can be inherited from to add methods' do
    class GraphPoint < Value.new(:x, :y)
      def inspect
        "GraphPoint at #{@x},#{@y}"
      end
    end

    c = GraphPoint.new(0,0)
    c.inspect.should == 'GraphPoint at 0,0'
  end

  it 'cannot be mutated' do
    p = Point.new(0,1)
    lambda { p.x = 1}.should raise_error
  end

  it 'cannot even be mutated inside a sublass with methods' do
    class Cow < Value.new(:color)
      def change_color(new_color)
        @color = new_color
      end
    end

    c = Cow.new("red")
    lambda {c.change_color("blue")}.should raise_error
  end

  it 'cannot be mutated using #instance_variable_set' do
    Money = Value.new(:amount, :denomination)
    m = Money.new(1, 'USD')
    lambda {m.instance_variable_set('@amount',2)}.should raise_error
  end

  describe '#hash and equality' do
    Y = Value.new(:x, :y)

    it 'is equal to another value with the same fields' do
      Point.new(0,0).should == Point.new(0,0)
    end

    it 'is not equal to an object with a different class' do
      Point.new(0,0).should_not == Y.new(0,0)
    end

    it 'is not equal to another value with different fields' do
      Point.new(0,0).should_not == Point.new(0,1)
      Point.new(0,0).should_not == Point.new(1,0)
    end

    it 'has an equal hash if the fields are equal' do
      p = Point.new(0,0)
      p.hash.should == Point.new(0,0).hash
    end

    it 'has a non-equal hash if the fields are different' do
      p = Point.new(0,0)
      p.hash.should_not == Point.new(1,0).hash
    end

    it 'does not have an equal hash if the class is different' do
      Point.new(0,0).hash.should_not == Y.new(0,0).hash
    end
  end
end
