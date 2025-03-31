require "spec"
require "../../src/io/serializable"

# Define a class for testing integer serialization
class IntegerTest
  include IO::Serializable

  # Standard Integer types
  property int8 : Int8
  property int16 : Int16
  property int32 : Int32
  property int64 : Int64
  property uint8 : UInt8
  property uint16 : UInt16
  property uint32 : UInt32
  property uint64 : UInt64

  # Nilable integer types
  property nilable_int8 : Int8?
  property nilable_int16 : Int16?
  property nilable_int32 : Int32?
  property nilable_int64 : Int64?
  property nilable_uint8 : UInt8?
  property nilable_uint16 : UInt16?
  property nilable_uint32 : UInt32?
  property nilable_uint64 : UInt64?

  # Default values
  property default_int : Int32 = 42
  property default_zero : Int32 = 0

  def initialize(
    @int8 = 0_i8,
    @int16 = 0_i16,
    @int32 = 0,
    @int64 = 0_i64,
    @uint8 = 0_u8,
    @uint16 = 0_u16,
    @uint32 = 0_u32,
    @uint64 = 0_u64,
    @nilable_int8 = nil,
    @nilable_int16 = nil,
    @nilable_int32 = nil,
    @nilable_int64 = nil,
    @nilable_uint8 = nil,
    @nilable_uint16 = nil,
    @nilable_uint32 = nil,
    @nilable_uint64 = nil
  )
  end

  def ==(other : IntegerTest)
    int8 == other.int8 &&
    int16 == other.int16 &&
    int32 == other.int32 &&
    int64 == other.int64 &&
    uint8 == other.uint8 &&
    uint16 == other.uint16 &&
    uint32 == other.uint32 &&
    uint64 == other.uint64 &&
    nilable_int8 == other.nilable_int8 &&
    nilable_int16 == other.nilable_int16 &&
    nilable_int32 == other.nilable_int32 &&
    nilable_int64 == other.nilable_int64 &&
    nilable_uint8 == other.nilable_uint8 &&
    nilable_uint16 == other.nilable_uint16 &&
    nilable_uint32 == other.nilable_uint32 &&
    nilable_uint64 == other.nilable_uint64 &&
    default_int == other.default_int &&
    default_zero == other.default_zero
  end
end

describe IO::Serializable do
  describe "integer serialization" do
    it "handles standard integer values" do
      test = IntegerTest.new(
        int8: 127_i8,
        int16: 32767_i16,
        int32: 2147483647,
        int64: 9223372036854775807_i64,
        uint8: 255_u8,
        uint16: 65535_u16,
        uint32: 4294967295_u32,
        uint64: 18446744073709551615_u64
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = IntegerTest.from_io(io)

      restored.int8.should eq 127_i8
      restored.int16.should eq 32767_i16
      restored.int32.should eq 2147483647
      restored.int64.should eq 9223372036854775807_i64
      restored.uint8.should eq 255_u8
      restored.uint16.should eq 65535_u16
      restored.uint32.should eq 4294967295_u32
      restored.uint64.should eq 18446744073709551615_u64
    end

    it "handles minimum integer values" do
      test = IntegerTest.new(
        int8: Int8::MIN,
        int16: Int16::MIN,
        int32: Int32::MIN,
        int64: Int64::MIN,
        uint8: 0_u8,
        uint16: 0_u16,
        uint32: 0_u32,
        uint64: 0_u64
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = IntegerTest.from_io(io)

      restored.int8.should eq Int8::MIN
      restored.int16.should eq Int16::MIN
      restored.int32.should eq Int32::MIN
      restored.int64.should eq Int64::MIN
      restored.uint8.should eq 0_u8
      restored.uint16.should eq 0_u16
      restored.uint32.should eq 0_u32
      restored.uint64.should eq 0_u64
    end

    it "handles maximum integer values" do
      test = IntegerTest.new(
        int8: Int8::MAX,
        int16: Int16::MAX,
        int32: Int32::MAX,
        int64: Int64::MAX,
        uint8: UInt8::MAX,
        uint16: UInt16::MAX,
        uint32: UInt32::MAX,
        uint64: UInt64::MAX
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = IntegerTest.from_io(io)

      restored.int8.should eq Int8::MAX
      restored.int16.should eq Int16::MAX
      restored.int32.should eq Int32::MAX
      restored.int64.should eq Int64::MAX
      restored.uint8.should eq UInt8::MAX
      restored.uint16.should eq UInt16::MAX
      restored.uint32.should eq UInt32::MAX
      restored.uint64.should eq UInt64::MAX
    end

    it "handles nilable integer with non-nil values" do
      test = IntegerTest.new(
        nilable_int8: 42_i8,
        nilable_int16: 1234_i16,
        nilable_int32: 123456,
        nilable_int64: 12345678901_i64,
        nilable_uint8: 200_u8,
        nilable_uint16: 60000_u16,
        nilable_uint32: 4000000000_u32,
        nilable_uint64: 10000000000000000000_u64
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = IntegerTest.from_io(io)

      restored.nilable_int8.should eq 42_i8
      restored.nilable_int16.should eq 1234_i16
      restored.nilable_int32.should eq 123456
      restored.nilable_int64.should eq 12345678901_i64
      restored.nilable_uint8.should eq 200_u8
      restored.nilable_uint16.should eq 60000_u16
      restored.nilable_uint32.should eq 4000000000_u32
      restored.nilable_uint64.should eq 10000000000000000000_u64
    end

    it "handles nilable integer with nil values" do
      test = IntegerTest.new(
        nilable_int8: nil,
        nilable_int16: nil,
        nilable_int32: nil,
        nilable_int64: nil,
        nilable_uint8: nil,
        nilable_uint16: nil,
        nilable_uint32: nil,
        nilable_uint64: nil
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = IntegerTest.from_io(io)

      restored.nilable_int8.should be_nil
      restored.nilable_int16.should be_nil
      restored.nilable_int32.should be_nil
      restored.nilable_int64.should be_nil
      restored.nilable_uint8.should be_nil
      restored.nilable_uint16.should be_nil
      restored.nilable_uint32.should be_nil
      restored.nilable_uint64.should be_nil
    end

    it "handles default values" do
      test = IntegerTest.new

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = IntegerTest.from_io(io)

      restored.default_int.should eq 42
      restored.default_zero.should eq 0
    end

    it "handles direct serialization of integer values" do
      # Using IO::Serializable's serialization helpers,
      # not direct to_io calls with byte format

      # Create a test with known values
      test = IntegerTest.new(
        int32: 123456,
        int64: 9223372036854775807_i64,
        uint8: 255_u8
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = IntegerTest.from_io(io)

      # Verify direct values
      restored.int32.should eq 123456
      restored.int64.should eq 9223372036854775807_i64
      restored.uint8.should eq 255_u8
    end

    it "handles integer in composite objects" do
      # Create a test instance with various integer configurations
      test = IntegerTest.new(
        int8: -100_i8,
        int16: -10000_i16,
        int32: -1000000,
        int64: -1000000000000_i64,
        uint8: 100_u8,
        uint16: 10000_u16,
        uint32: 1000000_u32,
        uint64: 1000000000000_u64,
        nilable_int32: 42,
        nilable_uint32: 24
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = IntegerTest.from_io(io)

      # Verify all fields match
      restored.should eq test
    end

    it "handles zero values correctly" do
      test = IntegerTest.new(
        int8: 0_i8,
        int16: 0_i16,
        int32: 0,
        int64: 0_i64,
        uint8: 0_u8,
        uint16: 0_u16,
        uint32: 0_u32,
        uint64: 0_u64
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = IntegerTest.from_io(io)

      restored.int8.should eq 0_i8
      restored.int16.should eq 0_i16
      restored.int32.should eq 0
      restored.int64.should eq 0_i64
      restored.uint8.should eq 0_u8
      restored.uint16.should eq 0_u16
      restored.uint32.should eq 0_u32
      restored.uint64.should eq 0_u64
    end

    it "handles negative values correctly" do
      test = IntegerTest.new(
        int8: -42_i8,
        int16: -1234_i16,
        int32: -123456,
        int64: -12345678901_i64
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = IntegerTest.from_io(io)

      restored.int8.should eq -42_i8
      restored.int16.should eq -1234_i16
      restored.int32.should eq -123456
      restored.int64.should eq -12345678901_i64
    end
  end
end
