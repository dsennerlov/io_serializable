require "spec"
require "../src/io_serializable"

describe IoSerializable do
  describe IoSerializable::Writer do
    describe "#write_string" do
      it "writes a string to an IO" do
        io = IO::Memory.new
        value = "Hello, World!"

        IoSerializable::Writer.write_string(io, value)

        io.rewind
        size = io.read_bytes(Int32)
        size.should eq value.bytesize

        buffer = Bytes.new(size)
        io.read_fully(buffer)
        String.new(buffer).should eq value
      end

      it "handles empty strings" do
        io = IO::Memory.new
        value = ""

        IoSerializable::Writer.write_string(io, value)

        io.rewind
        size = io.read_bytes(Int32)
        size.should eq 0
      end

      it "handles strings with special characters" do
        io = IO::Memory.new
        value = "Special chars: !@#$%^&*()_+{}💥[]|\\:;\"'<>,.?/"

        IoSerializable::Writer.write_string(io, value)

        io.rewind
        size = io.read_bytes(Int32)
        buffer = Bytes.new(size)
        io.read_fully(buffer)
        String.new(buffer).should eq value
      end
    end

    describe "#write_int" do
      it "writes Int32 to an IO" do
        io = IO::Memory.new
        value = 42_i32

        IoSerializable::Writer.write_int(io, value)

        io.rewind
        io.read_bytes(Int32).should eq value
      end

      it "writes Int64 to an IO" do
        io = IO::Memory.new
        value = 9223372036854775807_i64 # Int64::MAX

        IoSerializable::Writer.write_int(io, value)

        io.rewind
        io.read_bytes(Int64).should eq value
      end

      it "writes UInt8 to an IO" do
        io = IO::Memory.new
        value = 255_u8 # UInt8::MAX

        IoSerializable::Writer.write_int(io, value)

        io.rewind
        io.read_bytes(UInt8).should eq value
      end
    end

    describe "#write_float" do
      it "writes Float32 to an IO" do
        io = IO::Memory.new
        value = 3.14159_f32

        IoSerializable::Writer.write_float(io, value)

        io.rewind
        io.read_bytes(Float32).should eq value
      end

      it "writes Float64 to an IO" do
        io = IO::Memory.new
        value = 3.14159265358979_f64

        IoSerializable::Writer.write_float(io, value)

        io.rewind
        io.read_bytes(Float64).should eq value
      end
    end

    describe "#write_bool" do
      it "writes true to an IO" do
        io = IO::Memory.new

        IoSerializable::Writer.write_bool(io, true)

        io.rewind
        io.read_bytes(Int8).should eq 1
      end

      it "writes false to an IO" do
        io = IO::Memory.new

        IoSerializable::Writer.write_bool(io, false)

        io.rewind
        io.read_bytes(Int8).should eq 0
      end
    end

    describe "#write_char" do
      it "writes ASCII character to an IO" do
        io = IO::Memory.new
        value = 'A'

        IoSerializable::Writer.write_char(io, value)

        io.rewind
        # Skip padding bytes
        3.times { io.read_bytes(UInt8) }
        io.read_bytes(UInt8).should eq value.ord.to_u8
      end

      it "writes Unicode character to an IO" do
        io = IO::Memory.new
        value = '💥' # Multi-byte character

        IoSerializable::Writer.write_char(io, value)

        io.rewind
        # Read all 4 bytes
        bytes = Array(UInt8).new
        4.times do
          byte = io.read_bytes(UInt8)
          bytes << byte if byte != 0
        end

        # Convert back to char
        String.new(bytes.to_unsafe, bytes.size)[0].should eq value
      end
    end

    describe "#write_enum" do
      it "writes an enum to an IO" do
        io = IO::Memory.new
        value = TestEnum::Two

        IoSerializable::Writer.write_enum(io, value)

        io.rewind
        io.read_bytes(Int32).should eq value.value
      end
    end

    # describe "#write_tuple" do
    #   it "writes a tuple to an IO" do
    #     io = IO::Memory.new
    #     value = {"Alice", 30}

    #     IoSerializable::Writer.write_tuple(io, value)

    #     io.rewind
    #     # Read the string
    #     size = io.read_bytes(Int32)
    #     buffer = Bytes.new(size)
    #     io.read_fully(buffer)
    #     String.new(buffer).should eq "Alice"

    #     # Read the integer
    #     io.read_bytes(Int32).should eq 30
    #   end
    # end

  #   describe "#write_named_tuple" do
  #     it "writes a named tuple to an IO" do
  #       io = IO::Memory.new
  #       value = {name: "Alice", age: 30}

  #       IoSerializable::Writer.write_named_tuple(io, value)

  #       io.rewind

  #       # Read first key (name)
  #       key_size = io.read_bytes(Int32)
  #       key_buffer = Bytes.new(key_size)
  #       io.read_fully(key_buffer)
  #       String.new(key_buffer).should eq "name"

  #       # Read first value (Alice)
  #       value_size = io.read_bytes(Int32)
  #       value_buffer = Bytes.new(value_size)
  #       io.read_fully(value_buffer)
  #       String.new(value_buffer).should eq "Alice"

  #       # Read second key (age)
  #       key_size = io.read_bytes(Int32)
  #       key_buffer = Bytes.new(key_size)
  #       io.read_fully(key_buffer)
  #       String.new(key_buffer).should eq "age"

  #       # Read second value (30)
  #       io.read_bytes(Int32).should eq 30
  #     end
  #   end
  end

  describe IoSerializable::Reader do
    describe "#read_string" do
      it "reads a string from an IO" do
        value = "Hello, World!"
        io = IO::Memory.new

        # Write string size and content
        io.write_bytes(value.bytesize)
        io.write(value.to_slice)
        io.rewind

        result = IoSerializable::Reader.read_string(io)
        result.should eq value
      end

      it "handles empty strings" do
        io = IO::Memory.new

        # Write string size (0) for empty string
        io.write_bytes(0)
        io.rewind

        result = IoSerializable::Reader.read_string(io)
        result.should eq ""
      end

      it "handles strings with special characters" do
        value = "Special chars: !@#$%^&*()_+{}💥[]|\\:;\"'<>,.?/"
        io = IO::Memory.new

        # Write string size and content
        io.write_bytes(value.bytesize)
        io.write(value.to_slice)
        io.rewind

        result = IoSerializable::Reader.read_string(io)
        result.should eq value
      end
    end

    describe "#read_int" do
      it "reads Int32 from an IO" do
        value = 42_i32
        io = IO::Memory.new

        io.write_bytes(value)
        io.rewind

        result = IoSerializable::Reader.read_int(io, Int32)
        result.should eq value
      end

      it "reads Int64 from an IO" do
        value = 9223372036854775807_i64 # Int64::MAX
        io = IO::Memory.new

        io.write_bytes(value)
        io.rewind

        result = IoSerializable::Reader.read_int(io, Int64)
        result.should eq value
      end

      it "reads UInt8 from an IO" do
        value = 255_u8 # UInt8::MAX
        io = IO::Memory.new

        io.write_bytes(value)
        io.rewind

        result = IoSerializable::Reader.read_int(io, UInt8)
        result.should eq value
      end
    end

    describe "#read_float" do
      it "reads Float32 from an IO" do
        value = 3.14159_f32
        io = IO::Memory.new

        io.write_bytes(value)
        io.rewind

        result = IoSerializable::Reader.read_float(io, Float32)
        result.should eq value
      end

      it "reads Float64 from an IO" do
        value = 3.14159265358979_f64
        io = IO::Memory.new

        io.write_bytes(value)
        io.rewind

        result = IoSerializable::Reader.read_float(io, Float64)
        result.should eq value
      end
    end

    describe "#read_bool" do
      it "reads true from an IO" do
        io = IO::Memory.new

        io.write_bytes(1_i8)
        io.rewind

        result = IoSerializable::Reader.read_bool(io)
        result.should be_true
      end

      it "reads false from an IO" do
        io = IO::Memory.new

        io.write_bytes(0_i8)
        io.rewind

        result = IoSerializable::Reader.read_bool(io)
        result.should be_false
      end
    end

    describe "#read_char" do
      it "reads ASCII character from an IO" do
        value = 'A'
        io = IO::Memory.new

        # Write with padding
        3.times { io.write_bytes(0_u8) }
        io.write_bytes(value.ord.to_u8)
        io.rewind

        result = IoSerializable::Reader.read_char(io)
        result.should eq value
      end

      it "reads Unicode character from an IO" do
        value = '💥' # Multi-byte character
        io = IO::Memory.new

        # Write character bytes with padding if needed
        char_bytes = value.to_s.bytes
        padding = 4 - char_bytes.size
        padding.times { io.write_bytes(0_u8) }
        char_bytes.each { |byte| io.write_bytes(byte) }
        io.rewind

        result = IoSerializable::Reader.read_char(io)
        result.should eq value
      end
    end

    describe "#read_enum" do
      it "reads an enum from an IO" do
        value = TestEnum::Two
        io = IO::Memory.new

        io.write_bytes(value.value)
        io.rewind

        result = IoSerializable::Reader.read_enum(io, TestEnum)
        result.should eq value
      end
    end
  end
end

# Test enum for enum serialization tests
enum TestEnum
  One = 1
  Two = 2
  Three = 3
end

# Test struct for struct serialization tests
struct TestStruct
  getter name : String
  getter age : Int32

  def initialize(@name, @age)
  end

  def members
    [
      Member.new(:name, @name),
      Member.new(:age, @age)
    ]
  end

  struct Member
    getter name : Symbol
    getter value : String | Int32

    def initialize(@name, @value)
    end
  end
end
