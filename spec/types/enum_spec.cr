require "spec"
require "../../src/io/serializable"

# Define an enum for testing
enum EnumTestStatus
  Active = 1
  Inactive = 2
  Pending = 3
  Deleted = 4
end

# Define a class for testing enum serialization
class EnumTest
  include IO::Serializable

  property id : Int32
  property name : String
  property status : EnumTestStatus
  property optional_status : EnumTestStatus?

  def initialize(@id = 0, @name = "", @status = EnumTestStatus::Pending, @optional_status = nil)
  end

  def ==(other : EnumTest)
    id == other.id &&
    name == other.name &&
    status == other.status &&
    optional_status == other.optional_status
  end
end

describe IO::Serializable do
  describe "enum serialization" do
    it "serializes and deserializes enums" do
      # Create an object with an enum
      test = EnumTest.new(
        id: 42,
        name: "Test Object",
        status: EnumTestStatus::Active
      )

      # Serialize to IO
      io = IO::Memory.new
      test.to_io(io)

      # Deserialize from IO
      io.rewind
      restored_test = EnumTest.from_io(io)

      # Verify all fields match
      restored_test.id.should eq test.id
      restored_test.name.should eq test.name
      restored_test.status.should eq test.status
      restored_test.optional_status.should eq test.optional_status
    end

    it "serializes and deserializes nilable enums with values" do
      # Create an object with a nilable enum that has a value
      test = EnumTest.new(
        id: 42,
        name: "Test Object",
        status: EnumTestStatus::Active,
        optional_status: EnumTestStatus::Inactive
      )

      # Serialize to IO
      io = IO::Memory.new
      test.to_io(io)

      # Deserialize from IO
      io.rewind
      restored_test = EnumTest.from_io(io)

      # Verify all fields match
      restored_test.id.should eq test.id
      restored_test.name.should eq test.name
      restored_test.status.should eq test.status
      restored_test.optional_status.should eq test.optional_status
    end

    it "serializes and deserializes nilable enums with nil" do
      # Create an object with a nilable enum that is nil
      test = EnumTest.new(
        id: 43,
        name: "Test Object 2",
        status: EnumTestStatus::Pending,
        optional_status: nil
      )

      # Serialize to IO
      io = IO::Memory.new
      test.to_io(io)

      # Deserialize from IO
      io.rewind
      restored_test = EnumTest.from_io(io)

      # Verify all fields match
      restored_test.id.should eq test.id
      restored_test.name.should eq test.name
      restored_test.status.should eq test.status
      restored_test.optional_status.should eq test.optional_status
    end

    it "handles direct serialization of enum values" do
      # Serialize enum directly
      enum_value = EnumTestStatus::Deleted

      io = IO::Memory.new
      enum_value.to_io(io)
      io.rewind
      restored = EnumTestStatus.from_io(io)

      restored.should eq EnumTestStatus::Deleted
    end

    it "handles all possible enum values" do
      # Test each enum value
      [EnumTestStatus::Active, EnumTestStatus::Inactive, EnumTestStatus::Pending, EnumTestStatus::Deleted].each do |status|
        test = EnumTest.new(status: status)

        io = IO::Memory.new
        test.to_io(io)
        io.rewind
        restored = EnumTest.from_io(io)

        restored.status.should eq status
      end
    end

    it "maintains enum numeric values" do
      # Verify that numeric values are maintained
      test = EnumTest.new(status: EnumTestStatus::Active)
      test.status.value.should eq 1

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = EnumTest.from_io(io)

      restored.status.value.should eq 1
    end

    it "handles enum in composite objects" do
      # Create a test instance with various enum configurations
      test = EnumTest.new(
        id: 100,
        name: "Complex Test",
        status: EnumTestStatus::Inactive,
        optional_status: EnumTestStatus::Deleted
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = EnumTest.from_io(io)

      # Verify all fields match
      restored.should eq test
    end
  end
end
