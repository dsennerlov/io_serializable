require "../../io_serializable"

struct Bool
  def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
    IoSerializable::Writer.write_bool(io, self, format)
  end

  def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Bool
    return IoSerializable::Reader.read_bool(io, format)
  end
end
