# Simple immutable value objects for ruby.
#
# @example Make a new value class:
#   Point = Value.new(:x, :y)
#
# @example And use it:
#   p = Point.new(1, 0)
#   p.x
#   #=> 1
#   p.y
#   #=> 0
#
class Value
  # Create a new value class.
  #
  # @param  [Array<Symbol>] fields  Names of fields to create in the new value class
  # @param  [Proc]          block   Optionally, a block to further define the new value class
  # @return [Class]                 A new value class with the provided `fields`
  # @raise  [ArgumentError]         If no field names are provided
  def self.new(*fields, &block)
    raise ArgumentError.new('wrong number of arguments (0 for 1+)') if fields.empty?

    Class.new do
      attr_reader(:hash, *fields)

      # Unroll the fields into a series of assignment Ruby statements that can
      # be used inside of the initializer for the new class. This was introduced
      # in PR#56 as a performance optimization -- it ensures that this iteration
      # happens once per class, instead of happening once per instance of the
      # class.
      instance_var_assignments = Array.new(fields.length) do |idx|
        "@#{fields[idx]} = values[#{idx}]"
      end.join("\n")

      class_eval <<-RUBY
        def initialize(*values)
          if #{fields.size} != values.size
            raise ArgumentError.new("wrong number of arguments, \#{values.size} for #{fields.size}")
          end

          #{instance_var_assignments}

          @hash = self.class.hash ^ values.hash

          freeze
        end
      RUBY

      const_set :VALUE_ATTRS, fields

      def self.with(hash)
        num_recognized_keys = self::VALUE_ATTRS.count { |field| hash.key?(field) }

        if num_recognized_keys != hash.size
          unexpected_keys = hash.keys - self::VALUE_ATTRS
          raise ArgumentError.new("Unexpected hash keys: #{unexpected_keys}")
        end

        if num_recognized_keys != self::VALUE_ATTRS.size
          missing_keys = self::VALUE_ATTRS - hash.keys
          raise ArgumentError.new("Missing hash keys: #{missing_keys} (got keys #{hash.keys})")
        end

        new(*hash.values_at(*self::VALUE_ATTRS))
      end

      def ==(other)
        eql?(other)
      end

      # Optimized to check for same instance and for different hash code, and
      # avoids intermediate Array instantiation to check fields.
      def eql?(other)
        self.equal?(other) ||
          (
            self.class == other.class &&
              self.hash == other.hash &&
              self.class::VALUE_ATTRS.all? do |field|
                send(field) == other.send(field)
              end
          )
      end

      def values
        self.class::VALUE_ATTRS.map { |field| send(field) }
      end

      def inspect
        attributes = to_a.map { |field, value| "#{field}=#{value.inspect}" }.join(', ')
        "#<#{self.class.name} #{attributes}>"
      end

      def pretty_print(q)
        q.group(1, "#<#{self.class.name}", '>') do
          q.seplist(to_a, lambda { q.text ',' }) do |pair|
            field, value = pair
            q.breakable
            q.text field.to_s
            q.text '='
            q.group(1) do
              q.breakable ''
              q.pp value
            end
          end
        end
      end

      # Optimized to avoid intermediate Hash instantiations.
      def with(hash = {})
        return self if hash.empty?

        num_recognized_keys = self.class::VALUE_ATTRS.count { |field| hash.key?(field) }

        if num_recognized_keys != hash.size
          unexpected_keys = hash.keys - self.class::VALUE_ATTRS
          raise ArgumentError.new("Unexpected hash keys: #{unexpected_keys}")
        end

        args = self.class::VALUE_ATTRS.map do |field|
          hash.key?(field) ? hash[field] : send(field)
        end

        self.class.new(*args)
      end

      def to_h
        Hash[to_a]
      end

      def recursive_to_h
        Hash[to_a.map{|k, v| [k, Value.coerce_to_h(v)]}]
      end

      def to_a
        self.class::VALUE_ATTRS.map { |field| [field, send(field)] }
      end

      class_eval &block if block
    end
  end

  protected

  def self.coerce_to_h(v)
    case
    when v.is_a?(Hash)
      Hash[v.map{|hk, hv| [hk, coerce_to_h(hv)]}]
    when v.respond_to?(:map)
      v.map{|x| coerce_to_h(x)}
    when v && v.respond_to?(:to_h)
      v.to_h
    else
      v
    end
  end
end
