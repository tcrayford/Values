# Enable codecov.io on Ruby 1.9 and later on Travis CI
if RUBY_VERSION >= '1.9'
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
  if ENV['CI'] == 'true'
    require 'codecov'
    SimpleCov.formatter = SimpleCov::Formatter::Codecov
  end
end

# Require rspec and the actual library under test
require 'rspec'
require File.join(File.dirname(__FILE__), '..', 'lib', 'values')

describe Value do

  describe 'Value.new' do
    it 'raises argument error if given zero fields' do
      expect { Value.new }.to raise_error(ArgumentError, 'wrong number of arguments (0 for 1+)')
    end
  end

  Cell = Value.new(:alive)

  Point = Value.new(:x, :y)

  Rectangle = Value.new(:top_left, :bottom_right)

  Board = Value.new(:cells)

  describe '.new and the fields of a value class' do
    it 'stores a single field' do
      expect(Cell.new(true).alive).to eq(true)
    end

    it 'stores multiple values' do
      p = Point.new(0,1)
      expect(p.x).to eq(0)
      expect(p.y).to eq(1)
    end

    it 'raises argument errors if not given the right number of arguments' do
      expect { Point.new }.to raise_error(ArgumentError, 'wrong number of arguments, 0 for 2')
    end
  end

  class GraphPoint < Value.new(:x, :y)
    def inspect
      "GraphPoint at #{@x},#{@y}"
    end
  end

  it 'can be inherited from to add methods' do
    expect(GraphPoint.new(0,0).inspect).to eq('GraphPoint at 0,0')
  end

  it 'has a pretty string representation' do
    expect(Point.new(0, 1).inspect).to eq('#<Point x=0, y=1>')
  end

  Line = Value.new(:slope, :y_intercept) do
    def inspect
      "<Line: y=#{slope}x+#{y_intercept}>"
    end
  end

  it 'can be customized with a block' do
    expect(Line.new(2, 3).inspect).to eq('<Line: y=2x+3>')
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

  it 'cannot even be mutated inside a subclass with methods' do
    c = Cow.new('red')
    expect { c.change_color('blue') }.to raise_error
  end

  Money = Value.new(:amount, :denomination)

  it 'cannot be mutated using #instance_variable_set' do
    m = Money.new(1, 'USD')
    expect { m.instance_variable_set('@amount', 2) }.to raise_error
  end

  it 'can be instantiated with a hash' do
    one_dollar = Money.with(:amount => 1, :denomination => 'USD')
    expect(one_dollar.amount).to eq(1)
    expect(one_dollar.denomination).to eq('USD')
  end

  it 'errors if you instantiate it from a hash with unrecognised fields' do
    expect { Money.with(:unrecognized_field => 1, :amount => 2, :denomination => 'USD') }.to raise_error(ArgumentError)
  end

  it 'errors if you instantiate it from a hash with missing fields' do
    expect { Money.with({}) }.to raise_error(ArgumentError)
  end

  it 'does not error when fields are explicitly nil' do
    expect { Money.with(:amount => 1, :denomination => nil) }.not_to raise_error
  end

  describe '#hash and equality' do
    Y = Value.new(:x, :y)

    it 'is equal to another value with the same fields' do
      expect(Point.new(0,0)).to eq(Point.new(0,0))
    end

    it 'is not equal to an object with a different class' do
      expect(Point.new(0,0)).not_to eq(Y.new(0,0))
    end

    it 'is not equal to another value with different fields' do
      expect(Point.new(0,0)).not_to eq(Point.new(0,1))
      expect(Point.new(0,0)).not_to eq(Point.new(1,0))
    end

    it 'has an equal hash if the fields are equal' do
      expect(Point.new(0,0).hash).to eq(Point.new(0,0).hash)
    end

    it 'has a non-equal hash if the fields are different' do
      expect(Point.new(0,0).hash).not_to eq(Point.new(1,0).hash)
    end

    it 'does not have an equal hash if the class is different' do
      expect(Point.new(0,0).hash).not_to eq(Y.new(0,0).hash)
    end
  end

  describe '#values' do
    it 'returns an array of field values' do
      expect(Point.new(10, 13).values).to eq([10, 13])
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
    let(:b) { Point.new(Set.new([1, 2, 3]), Set.new([4, 5, 6])) }

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

      it 'handles nested args' do
        expect( b.with({:x => Set.new([1])})).to eq(Point.new(Set.new([1]), b.y))
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
    it 'returns a hash of fields and values' do
      expect(Point.new(1, -1).to_h).to eq({ :x => 1, :y => -1 })
    end

    it 'converts nested values' do
      expect(Rectangle.new(Point.new(0, 1), Point.new(1, 0)).to_h).to eq({:top_left => {:x => 0, :y => 1}, :bottom_right => {:x => 1, :y => 0}})
    end

    it 'converts values in an array field' do
      expect(Board.new([Cell.new(false), Cell.new(true)]).to_h).to eq({:cells => [{:alive => false}, {:alive => true}]})
    end

    it 'converts values in a hash field' do
      expect(Board.new({:mine => Cell.new(true), :yours => Cell.new(false)}).to_h).to eq({:cells => {:mine => {:alive => true}, :yours => {:alive => false}}})
    end
  end

  describe '#to_a' do
    it 'returns an array of pairs of fields and values' do
      expect(Point.new(1, -1).to_a).to eq([[:x, 1], [:y, -1]])
    end
  end
end
