class Value
  def self.new(*fields)
    Class.new do
      attr_reader *fields

      define_method(:initialize) do |*values|
        raise ArgumentError.new("wrong number of arguments, #{values.size} for #{fields.size}") if fields.size != values.size

        fields.zip(values) do |field, value|
          instance_variable_set(:"@#{field}", value)
        end

        freeze
      end

      const_set :VALUE_ATTRS, fields

      def self.with(hash)
        unexpected_keys = hash.keys - self::VALUE_ATTRS
        if unexpected_keys.any?
          raise ArgumentError.new("Unexpected hash keys: #{unexpected_keys}")
        end

        new(*hash.values_at(*self::VALUE_ATTRS))
      end

      def ==(other)
        eql?(other)
      end

      def eql?(other)
        self.class == other.class && values == other.values
      end

      def hash
        values.map(&:hash).inject(0, :+) + self.class.hash
      end

      def values
        self.class::VALUE_ATTRS.map { |field| send(field) }
      end
    end
  end
end
