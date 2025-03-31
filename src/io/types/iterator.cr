require "../../io_serializable"

module Iterator(T)
  def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
  end

  def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Iterator(T)
  end
end
