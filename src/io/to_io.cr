require "../io_serializable"

struct Bool
  def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
    IoSerializable::Writer.write_bool(io, self, format)
  end
end

class String
  def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
    IoSerializable::Writer.write_string(io, self, format)
  end
end

struct Char
  def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
    IoSerializable::Writer.write_char(io, self, format)
  end
end

struct Tuple
  def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
    {% for i in 0...T.size %}
      {% actual_type = T[i] %}
      {% if actual_type.has_method?(:to_io) %}
        self[{{i}}].not_nil!.to_io(io, format)
      {% elsif [Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64].includes?(actual_type) %}
        IoSerializable::Writer.write_int(io, self[{{i}}], format)
      {% elsif [Float32, Float64].includes?(actual_type) %}
        IoSerializable::Writer.write_float(io, self[{{i}}], format)
      {% elsif actual_type < Enum %}
        IoSerializable::Writer.write_enum(io, self[{{i}}], format)
      {% end %}
    {% end %}
  end
end

struct Enum
  def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
    IoSerializable::Writer.write_enum(io, self, format)
  end
end
