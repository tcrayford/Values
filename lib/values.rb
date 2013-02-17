class Value
  def self.new(*fields)
    return Class.new do
      attr_reader *fields

      define_method(:initialize) do |*input_fields|
        raise ArgumentError.new("wrong number of arguments, #{input_fields.size} for #{fields.size}") if fields.size != input_fields.size

        fields.each_with_index do |field, index|
          instance_variable_set(:"@#{field}", input_fields[index])
        end
        self.freeze
      end

      const_set :VALUE_ATTRS, fields

      def self.with(hash)
        unexpected_keys = hash.keys - self::VALUE_ATTRS
        if unexpected_keys.any?
          raise ArgumentError.new("Unexpected hash keys: #{unexpected_keys}")
        end

        self.new(*hash.values_at(*self::VALUE_ATTRS))
      end

      def ==(other)
        self.eql?(other)
      end

      def eql?(other)
        return false if other.class != self.class
        self.class::VALUE_ATTRS.all? do |field|
          self.send(field) == other.send(field)
        end
      end

      def hash
        result = 0
        self.class::VALUE_ATTRS.each do |field|
          result += self.send(field).hash
        end
        return result + self.class.hash
      end
    end
  end
end
