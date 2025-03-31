require "../../io_serializable"

class Hash
  def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
  end

  def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Hash
  end
end
