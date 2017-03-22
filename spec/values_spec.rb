# Enable codecov.io on Ruby 2.2 and later on Travis CI
if RUBY_VERSION >= '2.2'
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

  describe '#pretty_print' do
    let(:v) { ManyAttrs.new(6, 5, 4, 3, 2, 1) }

    it 'returns string with breaks after every value if any value is long' do
      expect(v.with(:f => 'a' * 70).pretty_inspect).to eq("#<ManyAttrs\n f=\"#{'a' * 70}\",\n e=5,\n d=4,\n c=3,\n b=2,\n a=1>\n")
    end

    it 'returns string with breaks after a field name if its line is very long' do
      expect(v.with(:f => 'a' * 80).pretty_inspect).to eq("#<ManyAttrs\n f=\n  \"#{'a' * 80}\",\n e=5,\n d=4,\n c=3,\n b=2,\n a=1>\n")
    end

    it 'returns the same as #inspect when no need to break lines' do
      expect(v.pretty_inspect).to eq("#{v.inspect}\n")
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

  describe '.from' do
    describe 'with valid arguments' do
      shared_examples 'happy path' do |input_name|
        context "when passed #{input_name}" do

          it 'creates a Value class from the object' do
            Value.stub(:klass_cache) { @memo ||= Hash.new }
            Value.should_receive(:new).with(:a, :b).and_call_original
            Value.from(input)
          end

          it 'returns an instance of the Value class' do
            result = Value.from(input)
            expect(result).to respond_to(:a)
            expect(result).to respond_to(:b)
          end

          it 'uses the same Value class across multiple calls' do
            object_1 = Value.from(input)
            object_2 = Value.from(input)

            expect(object_1.class).to eq(object_2.class)
          end
        end
      end

      include_examples 'happy path', 'a valid Hash' do
        let(:input) { { a: 1, b: 2} }
      end

      include_examples 'happy path', 'an object that coerces to Hash' do
        let(:input) do
          Object.new.tap  do |o|
            o.define_singleton_method(:to_hash) { {a: 1, b: 2} }
          end
        end
      end

      describe 'when passed an uncoercible object' do
        it 'raises an error' do
          expect { Value.from(Object.new) }.to raise_error(TypeError)
        end
      end
    end
  end

  describe '#to_h' do
    it 'returns a hash of fields and values' do
      expect(Point.new(1, -1).to_h).to eq({ :x => 1, :y => -1 })
    end
  end

  describe '#recursive_to_h' do
    it 'converts nested values' do
      expect(Rectangle.new(Point.new(0, 1), Point.new(1, 0)).recursive_to_h).to eq({:top_left => {:x => 0, :y => 1}, :bottom_right => {:x => 1, :y => 0}})
    end

    it 'converts values in an array field' do
      expect(Board.new([Cell.new(false), Cell.new(true)]).recursive_to_h).to eq({:cells => [{:alive => false}, {:alive => true}]})
    end

    it 'converts values in a hash field' do
      expect(Board.new({:mine => Cell.new(true), :yours => Cell.new(false)}).recursive_to_h).to eq({:cells => {:mine => {:alive => true}, :yours => {:alive => false}}})
    end
  end

  describe '#to_a' do
    it 'returns an array of pairs of fields and values' do
      expect(Point.new(1, -1).to_a).to eq([[:x, 1], [:y, -1]])
    end
  end
end
