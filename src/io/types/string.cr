require "../../io_serializable"

class String
  def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
    IoSerializable::Writer.write_string(io, self, format)
  end

  def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : String
    IoSerializable::Reader.read_string(io, format)
  end
end
