struct Bool
  def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Bool
    IoSerializable::Reader.read_bool(io, format)
  end
end
