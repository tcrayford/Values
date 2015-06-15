class Value
  def self.new(*fields, &block)
    raise ArgumentError.new('wrong number of arguments (0 for 1+)') if fields.empty?

    Class.new do
      attr_reader(:hash, *fields)

      define_method(:initialize) do |*values|
        raise ArgumentError.new("wrong number of arguments, #{values.size} for #{fields.size}") if fields.size != values.size

        fields.zip(values) do |field, value|
          instance_variable_set(:"@#{field}", value)
        end

        @hash = self.class.hash ^ values.hash

        freeze
      end

      const_set :VALUE_ATTRS, fields

      def self.with(hash)
        unexpected_keys = hash.keys - self::VALUE_ATTRS
        if unexpected_keys.any?
          raise ArgumentError.new("Unexpected hash keys: #{unexpected_keys}")
        end

        missing_keys = self::VALUE_ATTRS - hash.keys
        if missing_keys.any?
          raise ArgumentError.new("Missing hash keys: #{missing_keys} (got keys #{hash.keys})")
        end

        new(*hash.values_at(*self::VALUE_ATTRS))
      end

      def ==(other)
        eql?(other)
      end

      def eql?(other)
        self.class == other.class && values == other.values
      end

      def values
        self.class::VALUE_ATTRS.map { |field| send(field) }
      end

      def inspect
        attributes = to_h.map { |field, value| "#{field}=#{value.inspect}" }.join(", ")
        "#<#{self.class.name} #{attributes}>"
      end

      def with(hash = {})
        return self if hash.empty?
        self.class.with(to_h.merge(hash))
      end

      def to_h
        Hash[self.class::VALUE_ATTRS.zip(values)]
      end

      class_eval &block if block
    end
  end
end
