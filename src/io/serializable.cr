require "../io_serializable"

class IO
  annotation Field
  end

  module Serializable
    macro included
      {% verbatim do %}
        def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
          {% for ivar in @type.instance_vars %}
            {% skip_ivar = false %}
            {% ann = ivar.annotation(IO::Field) %}
            {% if ann && ann[:skip] %}
              {% skip_ivar = true %}
            {% end %}

            {% unless skip_ivar %}
              {% unless flag?(:spec) %}
                puts "DEBUG: Processing ivar {{ivar.name}} of type {{ivar.type}}"
              {% end %}

              # Check if type is nilable
              {% is_nilable = ivar.type.union? && ivar.type.union_types.includes?(Nil) %}
              {% if is_nilable %}
                # Write a flag indicating if the value is nil (1) or not (0)
                io.write_bytes(@{{ivar.name}}.nil? ? 1_i8 : 0_i8, format)
                {% unless flag?(:spec) %}
                  puts "DEBUG: Writing nil flag for {{ivar.name}}: #{@{{ivar.name}}.nil? ? 1 : 0}"
                {% end %}

                # If nil, skip writing the actual value
                unless @{{ivar.name}}.nil?
                  # Get the non-nil type for nilable types
                  {% actual_type = ivar.type.union_types.reject { |t| t == Nil }.first %}

                  {% if [String].includes?(actual_type) %}
                    IoSerializable::Writer.write_string(io, @{{ivar.name}}.not_nil!, format)

                  {% elsif [Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64].includes?(actual_type) %}
                    IoSerializable::Writer.write_int(io, @{{ivar.name}}.not_nil!, format)

                  {% elsif [Float32, Float64].includes?(actual_type) %}
                    IoSerializable::Writer.write_float(io, @{{ivar.name}}.not_nil!, format)

                  {% elsif [Bool].includes?(actual_type) %}
                    IoSerializable::Writer.write_bool(io, @{{ivar.name}}.not_nil!, format)

                  {% elsif [Char].includes?(actual_type) %}
                    IoSerializable::Writer.write_char(io, @{{ivar.name}}.not_nil!, format)

                  # {% elsif actual_type.name.starts_with?("Array") %}
                  #   {% unless flag?(:spec) %}
                  #     puts "DEBUG: Writing array {{ivar.name}} = #{@{{ivar.name}}}"
                  #   {% end %}
                  #   @{{ivar.name}}.not_nil!.to_io(io, format)

                  {% elsif actual_type.has_method?("to_io") %}
                    {% unless flag?(:spec) %}
                      puts "DEBUG: Writing nested object {{ivar.name}} = #{@{{ivar.name}}}"
                    {% end %}
                    @{{ivar.name}}.not_nil!.to_io(io, format)
                  {% else %}
                    raise "Type {{actual_type}} of {{ivar.name}} is not supported for serialization"
                  {% end %}
                end
              {% else %}
                # Non-nilable types
                {% if [String].includes?(ivar.type) %}
                  IoSerializable::Writer.write_string(io, @{{ivar.name}}, format)

                {% elsif [Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64].includes?(ivar.type) %}
                  IoSerializable::Writer.write_int(io, @{{ivar.name}}, format)

                {% elsif [Float32, Float64].includes?(ivar.type) %}
                  IoSerializable::Writer.write_float(io, @{{ivar.name}}, format)

                {% elsif [Bool].includes?(ivar.type) %}
                  IoSerializable::Writer.write_bool(io, @{{ivar.name}}, format)

                {% elsif [Char].includes?(ivar.type) %}
                  IoSerializable::Writer.write_char(io, @{{ivar.name}}.not_nil!, format)

                # {% elsif ivar.type.name.starts_with?("Array") %}
                #   {% unless flag?(:spec) %}
                #     puts "DEBUG: Writing array {{ivar.name}} = #{@{{ivar.name}}}"
                #   {% end %}
                #   @{{ivar.name}}.to_io(io, format)

                {% elsif ivar.type.has_method?("to_io") %}
                  {% unless flag?(:spec) %}
                    puts "DEBUG: Writing nested object {{ivar.name}} = #{@{{ivar.name}}}"
                  {% end %}
                  @{{ivar.name}}.to_io(io, format)
                {% else %}
                  raise "Type {{ivar.type}} of {{ivar.name}} is not supported for serialization"
                {% end %}
              {% end %}
            {% end %}
          {% end %}
        end

        # Define from_io method
        def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : self
          {% unless flag?(:spec) %}
            puts "DEBUG: Starting from_io for #{self}"
          {% end %}

          # Create a new instance
          #instance = new
          instance = allocate
          instance.initialize

          {% for ivar in @type.instance_vars %}
            {% skip_ivar = false %}
            {% ann = ivar.annotation(IO::Field) %}
            {% if ann && ann[:skip] %}
              {% skip_ivar = true %}
            {% end %}

            {% unless skip_ivar %}
              {% unless flag?(:spec) %}
                puts "DEBUG: Processing ivar {{ivar.name}} of type {{ivar.type}}"
              {% end %}

              # Check if type is nilable
              {% is_nilable = ivar.type.union? && ivar.type.union_types.includes?(Nil) %}
              {% if is_nilable %}
                # Read the nil flag
                nil_flag = io.read_bytes(Int8, format)
                {% unless flag?(:spec) %}
                  puts "DEBUG: Read nil flag for {{ivar.name}}: #{nil_flag}"
                {% end %}

                # If the value is nil, use the _set_nil method
                if nil_flag == 1
                  # DANGER ZONE: This is a hack to set the value to nil
                  pointerof(instance.@{{ivar.name}}).value = nil
                  {% unless flag?(:spec) %}
                    puts "DEBUG: Setting {{ivar.name}} to nil"
                  {% end %}
                else
                  # Get the non-nil type for nilable types
                  {% actual_type = ivar.type.union_types.reject { |t| t == Nil }.first %}

                  {% if [String].includes?(actual_type) %}
                    instance.{{ivar.name}} =IoSerializable::Reader.read_string(io)

                  {% elsif [Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64].includes?(actual_type) %}
                    instance.{{ivar.name}} = IoSerializable::Reader.read_int(io, {{actual_type}}, format)

                  {% elsif [Float32, Float64].includes?(actual_type) %}
                    instance.{{ivar.name}} = IoSerializable::Reader.read_float(io, {{actual_type}}, format)

                  {% elsif [Bool].includes?(actual_type) %}
                    instance.{{ivar.name}} = IoSerializable::Reader.read_bool(io, format)

                  {% elsif [Char].includes?(actual_type) %}
                    instance.{{ivar.name}} = IoSerializable::Reader.read_char(io, format)

                  # {% elsif actual_type.name.starts_with?("Array") %}
                  #   {% element_type = actual_type.type_vars[0] %}
                  #   instance.{{ivar.name}} = Array({{element_type}}).from_io(io, {{element_type}}, format)
                  #   {% unless flag?(:spec) %}
                  #     puts "DEBUG: Read array: #{instance.{{ivar.name}}} for {{ivar.name}}"
                  #   {% end %}

                  {% else %}
                    # For nested objects that include IO::Serializable
                    instance.{{ivar.name}} = {{actual_type}}.from_io(io, format)
                    {% unless flag?(:spec) %}
                      puts "DEBUG: Read nested object: #{instance.{{ivar.name}}} for {{ivar.name}}"
                    {% end %}
                  {% end %}
                end
              {% else %}
                # Non-nilable types
                {% if [String].includes?(ivar.type) %}
                  instance.{{ivar.name}} =IoSerializable::Reader.read_string(io)

                {% elsif [Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64].includes?(ivar.type) %}
                  instance.{{ivar.name}} = IoSerializable::Reader.read_int(io, {{ivar.type}}, format)

                {% elsif [Float32, Float64].includes?(ivar.type) %}
                  instance.{{ivar.name}} = IoSerializable::Reader.read_float(io, {{ivar.type}}, format)

                {% elsif [Bool].includes?(ivar.type) %}
                  instance.{{ivar.name}} = IoSerializable::Reader.read_bool(io, format)

                {% elsif [Char].includes?(ivar.type) %}
                  instance.{{ivar.name}} = IoSerializable::Reader.read_char(io, format)

                # {% elsif ivar.type.name.starts_with?("Array") %}
                #   {% element_type = ivar.type.type_vars[0] %}
                #   instance.{{ivar.name}} = Array({{element_type}}).from_io(io, {{element_type}}, format)
                #   {% unless flag?(:spec) %}
                #     puts "DEBUG: Read array: #{instance.{{ivar.name}}} for {{ivar.name}}"
                #   {% end %}

                {% else %}
                  # For nested objects that include IO::Serializable
                  instance.{{ivar.name}} = {{ivar.type}}.from_io(io, format)
                  {% unless flag?(:spec) %}
                    puts "DEBUG: Read nested object: #{instance.{{ivar.name}}} for {{ivar.name}}"
                  {% end %}
                {% end %}
              {% end %}
            {% end %}
          {% end %}

          {% unless flag?(:spec) %}
            puts "DEBUG: Finished from_io"
          {% end %}
          instance
        end
      {% end %}
    end
  end
end
