require "./io/serializable"
require "./version"

module IoSerializable

  module Writer
    extend self

    def write_nil_flag(io : IO, value : Bool, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
      io.write_bytes(value ? 1_i8 : 0_i8, format)
    end

    def write_string(io : IO, value : String, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
      bytesize = value.bytesize
      io.write_bytes(bytesize, format)
      io.write(value.to_slice)
    end

    def write_int(io : IO, value : Int::Primitive, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
      io.write_bytes(value, format)
    end

    def write_float(io : IO, value : Float::Primitive, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
      io.write_bytes(value, format)
    end

    def write_bool(io : IO, value : Bool, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
      io.write_bytes(value ? 1_i8 : 0_i8, format)
    end

    def write_char(io : IO, value : Char, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
      bytesize = sizeof(Char)
      char_bytes = value.to_s.bytes
      padding = 4 - char_bytes.size
      padding.times { io.write_bytes(0_u8, format) }

      char_bytes.each do |byte|
        io.write_bytes(byte, format)
      end
    end

    def write_enum(io : IO, value : Enum, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
      write_int(io, value.value, format)
    end
  end

  module Reader
    extend self

    def read_nil_flag(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Int8
      return io.read_bytes(Int8, format)
    end

    def read_string(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : String
      size = io.read_bytes(Int32, format)
      buffer = Bytes.new(size)
      io.read_fully(buffer)
      return String.new(buffer)
    end

    def read_int(io : IO, type : T.class, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : T forall T
      io.read_bytes(type, format)
    end

    def read_float(io : IO, type : T.class, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : T forall T
      io.read_bytes(type, format)
    end

    def read_bool(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Bool
      value = io.read_bytes(Int8, format)
      return value != 0
    end

    def read_char(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Char
      char_bytes = Array(UInt8).new
      4.times do |i|
        byte = io.read_bytes(UInt8, format)
        # Only add non-zero bytes to avoid null termination issues
        char_bytes << byte if byte != 0
      end

      # Convert bytes to string and get first char (or default to space if empty)
      char_str = String.new(char_bytes.to_unsafe, char_bytes.size)
      return char_str.empty? ? ' ' : char_str[0]
    end

    def read_enum(io : IO, type : T.class, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : T forall T
      value = io.read_bytes(Int32, format)
      type.from_value(value)
    end
  end
end
