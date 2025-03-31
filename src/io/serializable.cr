require "../io_serializable"
require "./to_io"
require "./from_io"

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

                {% if actual_type.has_method?("to_io") %}
                  @{{name}}.not_nil!.to_io(io, format)
                {% elsif [Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64].includes?(actual_type) %}
                  IoSerializable::Writer.write_int(io, @{{name}}.not_nil!, format)
                {% elsif [Float32, Float64].includes?(actual_type) %}
                  IoSerializable::Writer.write_float(io, @{{name}}.not_nil!, format)
                {% else %}
                  {% if flag?(:io_debug) %}
                    puts "Type {{actual_type}} of {{name}} is not supported for serialization"
                  {% end %}
                {% end %}
              end
            {% end %}
          {% end %}
        end

        def initialize(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
          initialize

          {% begin %}
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

              {% if value[:nilable] %}
                is_{{name}}_nil = IoSerializable::Reader.read_nil_flag(io, format)

                if 1 == is_{{name}}_nil
                  pointerof(@{{name}}).value = nil
                else
              {% end %}

              {% actual_type = value[:actual_type].is_a?(Generic) ? value[:actual_type].name.resolve : value[:actual_type] %}

              {% if actual_type <= IO::Serializable %}
                @{{name}} = {{actual_type}}.from_io(io, format)
              {% elsif actual_type.class.has_method?(:from_io) %}
                @{{name}} = {{actual_type}}.from_io(io, format)
              {% elsif [Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64].includes?(actual_type) %}
                @{{name}} = IoSerializable::Reader.read_int(io, {{actual_type}}, format)
              {% elsif [Float32, Float64].includes?(actual_type) %}
                @{{name}} = IoSerializable::Reader.read_float(io, {{actual_type}}, format)
              {% else %}
                {% if flag?(:io_debug) %}
                  puts "Property {{name}} of type {{actual_type}} is not supported for deserialization"
                {% end %}
              {% end %}

              {% if value[:nilable] %}
                end
              {% end %}
            {% end %}
          {% end %}
        end

        def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : self
          # instance = allocate
          # instance.initialize(io, format)
          # return instance
          return new(io, format)
        end
      {% end %}
    end
  end
end
