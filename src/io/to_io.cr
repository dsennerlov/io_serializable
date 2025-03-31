struct Bool
  def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
    IoSerializable::Writer.write_bool(io, self, format)
  end
end

struct Tuple
  def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
    {% for i in 0...T.size %}
      {% actual_type = T[i] %}
      {% if actual_type.has_method?("to_io") %}
        self[{{i}}].not_nil!.to_io(io, format)
      {% elsif [Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64].includes?(actual_type) %}
        IoSerializable::Writer.write_int(io, self[{{i}}], format)
      {% elsif [Float32, Float64].includes?(actual_type) %}
        IoSerializable::Writer.write_float(io, self[{{i}}], format)
      {% elsif [Bool].includes?(actual_type) %}
        IoSerializable::Writer.write_bool(io, self[{{i}}], format)
      {% elsif [Char].includes?(actual_type) %}
        IoSerializable::Writer.write_char(io, self[{{i}}], format)
      {% elsif actual_type < Enum %}
        IoSerializable::Writer.write_enum(io, self[{{i}}], format)
      {% end %}
    {% end %}
  end

  def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : self
    {% begin %}
      Tuple.new(
        {% for i in 0...T.size %}
          {% actual_type = T[i] %}
          {% if actual_type.has_method?("from_io") %}
            {{actual_type}}.from_io(io, format),
          {% elsif [String].includes?(actual_type) %}
            IoSerializable::Reader.read_string(io, format),
          {% elsif [Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64].includes?(actual_type) %}
            IoSerializable::Reader.read_int(io, {{actual_type}}, format),
          {% elsif [Float32, Float64].includes?(actual_type) %}
            IoSerializable::Reader.read_float(io, {{actual_type}}, format),
          {% elsif [Bool].includes?(actual_type) %}
            IoSerializable::Reader.read_bool(io, format),
          {% elsif [Char].includes?(actual_type) %}
            IoSerializable::Reader.read_char(io, format),
          {% elsif actual_type < Enum %}
            IoSerializable::Reader.read_enum(io, {{actual_type}}, format),
          {% end %}
        {% end %}
      )
    {% end %}
  end
end

class String
  def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
    IoSerializable::Writer.write_string(io, self, format)
  end
end
