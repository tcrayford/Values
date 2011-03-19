class Value
  def self.new(*fields)
    return Class.new do
      attr_reader *fields
      define_method(:initialize) do |*input_fields|
        raise ArgumentError.new("wrong number of arguments, #{input_fields.size} for #{fields.size}") if fields.size != input_fields.size

        fields.each_with_index do |field, index|
          instance_variable_set('@' + field.to_s, input_fields[index])
        end
        self.freeze
      end
    end
  end
end
