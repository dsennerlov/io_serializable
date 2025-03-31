require "../io_serializable"

struct Bool
  def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Bool
    IoSerializable::Reader.read_bool(io, format)
  end
end

struct Tuple
  def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : self
    {% begin %}
      Tuple.new(
        {% for i in 0...T.size %}
          {% actual_type = T[i] %}
          {% if actual_type.class.has_method?(:from_io) %}
            {{actual_type}}.from_io(io, format),
          {% elsif [String].includes?(actual_type) %}
            IoSerializable::Reader.read_string(io, format),
          {% elsif [Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64].includes?(actual_type) %}
            IoSerializable::Reader.read_int(io, {{actual_type}}, format),
          {% elsif [Float32, Float64].includes?(actual_type) %}
            IoSerializable::Reader.read_float(io, {{actual_type}}, format),
          {% elsif actual_type < Enum %}
            IoSerializable::Reader.read_enum(io, {{actual_type}}, format),
          {% end %}
        {% end %}
      )
    {% end %}
  end
end

class String
  def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : String
    IoSerializable::Reader.read_string(io, format)
  end
end

struct Char
  def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Char
    IoSerializable::Reader.read_char(io, format)
  end
end

struct Enum
  def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : self
    IoSerializable::Reader.read_enum(io, self, format)
  end
end
