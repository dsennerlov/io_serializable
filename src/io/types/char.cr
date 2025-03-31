require "../../io_serializable"

struct Char
  def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
    IoSerializable::Writer.write_char(io, self, format)
  end

  def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Char
    IoSerializable::Reader.read_char(io, format)
  end
end
