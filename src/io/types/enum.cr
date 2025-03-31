require "../../io_serializable"

struct Enum
  def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
    IoSerializable::Writer.write_enum(io, self, format)
  end

  def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : self
    IoSerializable::Reader.read_enum(io, self, format)
  end
end