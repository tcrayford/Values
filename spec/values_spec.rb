require File.expand_path(File.dirname(__FILE__) + '/../lib/values')
describe 'values' do
  it 'raises argument error if given zero fields' do
    expect { Value.new }.to raise_error(ArgumentError, 'wrong number of arguments (0 for 1+)')
  end

  Cell = Value.new(:alive)

  it 'stores a single field' do
    c = Cell.new(true)
    c.alive.should == true
  end

  Point = Value.new(:x, :y)

  it 'stores multiple values' do
    p = Point.new(0,1)
    p.x.should == 0
    p.y.should == 1
  end

  it 'raises argument errors if not given the right number of arguments' do
    expect { Point.new }.to raise_error(ArgumentError, 'wrong number of arguments, 0 for 2')
  end

  class GraphPoint < Value.new(:x, :y)
    def inspect
      "GraphPoint at #{@x},#{@y}"
    end
  end

  it 'can be inherited from to add methods' do
    c = GraphPoint.new(0,0)
    c.inspect.should == 'GraphPoint at 0,0'
  end

  it 'has a pretty string representation' do
    p = Point.new(0, 1)
    p.inspect.should == "#<Point x=0, y=1>"
  end

  Line = Value.new(:slope, :y_intercept) do
    def inspect
      "<Line: y=#{slope}x+#{y_intercept}>"
    end
  end

  it 'can be customized with a block' do
    l = Line.new(2, 3)
    l.inspect.should == '<Line: y=2x+3>'
  end

  it 'cannot be mutated' do
    p = Point.new(0,1)
    expect { p.x = 1 }.to raise_error
  end

  class Cow < Value.new(:color)
    def change_color(new_color)
      @color = new_color
    end
  end

  it 'cannot even be mutated inside a sublass with methods' do
    c = Cow.new("red")
    expect { c.change_color("blue") }.to raise_error
  end

  Money = Value.new(:amount, :denomination)

  it 'cannot be mutated using #instance_variable_set' do
    m = Money.new(1, 'USD')
    expect { m.instance_variable_set('@amount', 2) }.to raise_error
  end

  it 'can be instantiated with a hash' do
    one_dollar = Money.with(:amount => 1, :denomination => 'USD')
    one_dollar.amount.should == 1
    one_dollar.denomination.should == 'USD'
  end

  it 'errors if you instantiate it from a hash with unrecognised fields' do
    expect do
      Money.with(:unrecognized_field => 1, :amount => 2, :denomination => 'USD')
    end.to raise_error
  end

  it 'errors if you instantiate it from a hash with missing fields' do
    expect do
      Money.with({})
    end.to raise_error(ArgumentError)
  end

  it 'does not error when fields are explicitly nil' do
    expect do
      Money.with(:amount => 1, :denomination => nil)
    end.not_to raise_error
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

  describe '#values' do
    it 'returns an array of field values' do
      Point.new(10, 13).values.should == [10, 13]
    end
  end

  ManyAttrs = Value.new(:f, :e, :d, :c, :b, :a)

  describe '#inspect' do
    let(:v) { ManyAttrs.new(6, 5, 4, 3, 2, 1) }

    it 'returns a string containing attributes in their expected order' do
      expect(v.inspect).to eq('#<ManyAttrs f=6, e=5, d=4, c=3, b=2, a=1>')
    end
  end

  describe '#with' do
    let(:p) { Point.new(1, -1) }

    describe 'with no arguments' do
      it 'returns an object equal by value' do
        expect(p.with).to eq(p)
      end

      it 'returns an object equal by identity' do
        expect(p.with).to equal(p)
      end
    end

    describe 'with hash arguments' do
      it 'replaces all field values' do
        expect(p.with({ :x => 1, :y => 2 })).to eq(Point.new(1, 2))
      end

      it 'defaults to current values if missing' do
        expect(p.with({ :y => 2 })).to eq(Point.new(1, 2))
      end

      it 'raises argument error if unknown field' do
        expect { p.with({ :foo => 3 }) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#to_h' do
    let(:p) { Point.new(1, -1) }

    it 'returns a hash of fields and values' do
      expect(p.to_h).to eq({ :x => 1, :y => -1 })
    end
  end

  describe '#to_a' do
    let(:p) { Point.new(1, -1) }

    it 'returns an array of pairs of fields and values' do
      expect(p.to_a).to eq([[:x, 1], [:y, -1]])
    end
  end
end
