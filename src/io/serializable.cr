require "../io_serializable"

class IO
  annotation Field
  end

  module Serializable
    macro included
      {% verbatim do %}
        def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
          {% begin %}
            {% properties = {} of Nil => Nil %}
            {% for ivar in @type.instance_vars %}
              {% ann = ivar.annotation(::IO::Field) %}
              {% unless ann && (ann[:skip] || ann[:skip_serialize]) %}
                {%
                  properties[ivar.id] = {
                    key:         ((ann && ann[:key]) || ivar).id,
                    has_default: ivar.has_default_value?,
                    default:     ivar.default_value,
                    nilable:     ivar.type.nilable?,
                    actual_type: ivar.type.union_types.reject { |t| t == Nil }.first,
                    type:        ivar.type,
                  }
                %}
              {% end %}
            {% end %}

            {% for _, value in properties %}
              {% name = value[:key] %}

              if {{value[:nilable]}}
                IoSerializable::Writer.write_nil_flag(io, @{{name}}.nil?, format)
              end

              unless @{{name}}.nil?
                {% actual_type = value[:actual_type] %}

                {% if [String].includes?(actual_type) %}
                  IoSerializable::Writer.write_string(io, @{{name}}.not_nil!, format)
                {% elsif [Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64].includes?(actual_type) %}
                  IoSerializable::Writer.write_int(io, @{{name}}.not_nil!, format)
                {% elsif [Float32, Float64].includes?(actual_type) %}
                  IoSerializable::Writer.write_float(io, @{{name}}.not_nil!, format)
                {% elsif [Bool].includes?(actual_type) %}
                  IoSerializable::Writer.write_bool(io, @{{name}}.not_nil!, format)
                {% elsif [Char].includes?(actual_type) %}
                  IoSerializable::Writer.write_char(io, @{{name}}.not_nil!, format)
                {% elsif actual_type.has_method?("to_io") %}
                  @{{name}}.not_nil!.to_io(io, format)
                {% else %}
                  raise "Type {{actual_type}} of {{name}} is not supported for serialization"
                {% end %}
              end
            {% end %}
          {% end %}
        end

        def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : self
          {% begin %}
            {% unless flag?(:spec) %}
              puts "DEBUG: Starting from_io for #{self}"
            {% end %}

            instance = allocate
            instance.initialize

            {% properties = {} of Nil => Nil %}
            {% for ivar in @type.instance_vars %}
              {% ann = ivar.annotation(::IO::Field) %}
              {% unless ann && ann[:skip] %}
                {%
                  properties[ivar.id] = {
                    key:         ((ann && ann[:key]) || ivar).id,
                    has_default: ivar.has_default_value?,
                    default:     ivar.default_value,
                    nilable:     ivar.type.nilable?,
                    actual_type: ivar.type.union_types.reject { |t| t == Nil }.first,
                    type:        ivar.type,
                  }
                %}
              {% end %}
            {% end %}

            {% for _, value in properties %}
              {% name = value[:key] %}

              # IGNORE: BEGIN
              {% if value[:nilable] %}
#                is_{{name}}_nil = io.read_bytes(Int8, format)
                is_{{name}}_nil = IoSerializable::Reader.read_nil_flag(io, format)

                if 1 == is_{{name}}_nil
                  pointerof(instance.@{{name}}).value = nil
                else
              {% end %}
              # IGNORE: END

              {% actual_type = value[:actual_type] %}

              {% if [String].includes?(actual_type) %}
                instance.{{name}} = IoSerializable::Reader.read_string(io, format)
              {% elsif [Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64].includes?(actual_type) %}
                instance.{{name}} = IoSerializable::Reader.read_int(io, {{actual_type}}, format)
              {% elsif [Float32, Float64].includes?(actual_type) %}
                instance.{{name}} = IoSerializable::Reader.read_float(io, {{actual_type}}, format)
              {% elsif [Bool].includes?(actual_type) %}
                instance.{{name}} = IoSerializable::Reader.read_bool(io, format)
              {% elsif [Char].includes?(actual_type) %}
                instance.{{name}} = IoSerializable::Reader.read_char(io, format)
              {% else %}
                if {{actual_type}}.responds_to?(:from_io)
                  instance.{{name}} = {{actual_type}}.from_io(io, format)
                else
                  puts "Property {{name}} of type {{actual_type}} is not supported for deserialization"
                end
              {% end %}

              # E: BEGIN
              {% if value[:nilable] %}
                end
              {% end %}
              # IGNORE: END
            {% end %}

            {% unless flag?(:spec) %}
              puts "DEBUG: Finished from_io"
            {% end %}

            return instance
          {% end %}
        end
      {% end %}
    end
  end
end
