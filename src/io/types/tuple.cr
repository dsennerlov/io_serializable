require "../../io_serializable"

struct Tuple
  def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
    {% for i in 0...T.size %}
      {% actual_type = T[i].union_types.reject { |t| t == Nil }.first %}

      {% if T[i].nilable? %}
        IoSerializable::Writer.write_nil_flag(io, self[{{i}}].nil?, format)
      {% end %}

      unless self[{{i}}].nil?
        {% if actual_type.has_method?(:to_io) %}
          self[{{i}}].not_nil!.to_io(io, format)
        {% elsif [Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64].includes?(actual_type) %}
          IoSerializable::Writer.write_int(io, self[{{i}}], format)
        {% elsif [Float32, Float64].includes?(actual_type) %}
          IoSerializable::Writer.write_float(io, self[{{i}}], format)
        {% end %}
      end
    {% end %}
  end

  def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : self
    {% begin %}
      return Tuple.new(
        {% for i in 0...T.size %}
          {% actual_type = T[i].union_types.reject { |t| t == Nil }.first %}

          {% if T[i].nilable? %}
            1 == IoSerializable::Reader.read_nil_flag(io, format) ? nil :
          {% end %}

          {% if actual_type.class.has_method?(:from_io) %}
            {{actual_type}}.from_io(io, format),
          {% elsif [Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64].includes?(actual_type) %}
            IoSerializable::Reader.read_int(io, {{actual_type}}, format),
          {% elsif [Float32, Float64].includes?(actual_type) %}
            IoSerializable::Reader.read_float(io, {{actual_type}}, format),
          {% end %}
        {% end %}
      )
    {% end %}
  end
end