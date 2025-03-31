require "spec"
require "../../src/io/serializable"

# Define an enum for testing
enum NamedTupleTestStatus
  Active = 1
  Inactive = 2
  Pending = 3
  Deleted = 4
end

# Define a simple Address class for testing
class Address
  include IO::Serializable

  property street : String
  property city : String

  def initialize(@street = "", @city = "")
  end

  def ==(other : Address)
    street == other.street && city == other.city
  end
end

# Define a class for testing named tuple serialization
class NamedTupleTest
  include IO::Serializable

  property simple_named_tuple : NamedTuple(id: Int32, name: String, value: Float64, active: Bool) = {id: 0, name: "", value: 0.0, active: false}
  property nested_named_tuple : NamedTuple(info: NamedTuple(label: String, count: Int32), score: Float64) = {info: {label: "", count: 0}, score: 0.0}
  property nilable_named_tuple : NamedTuple(id: Int32?, name: String, value: Float64?, active: Bool) = {id: nil, name: "", value: nil, active: false}
  property nilable_nested_named_tuple : NamedTuple(info: NamedTuple(label: String, count: Int32)?, score: Float64?) = {info: nil, score: nil}
  property enum_named_tuple : NamedTuple(status: NamedTupleTestStatus, optional_status: NamedTupleTestStatus?) = {status: NamedTupleTestStatus::Active, optional_status: nil}

  def initialize
  end
end

# Define a class for testing composite named tuple serialization
class NamedTupleCompositeTest
  include IO::Serializable

  property title : String
  property data : NamedTuple(x: Int32, y: Float64)

  def initialize(@title = "", @data = {x: 0, y: 0.0})
  end

  def ==(other : NamedTupleCompositeTest)
    title == other.title && data == other.data
  end
end

describe IO::Serializable do
  describe "named tuple serialization" do
    it "serializes and deserializes named tuple properties" do
      # Create a test class instance with named tuple property
      named_tuple_test = NamedTupleTest.new
      named_tuple_test.simple_named_tuple = {id: 42, name: "hello", value: 3.14, active: true}
      named_tuple_test.nested_named_tuple = {info: {label: "nested", count: 99}, score: 123.456}

      # Serialize to IO
      io = IO::Memory.new
      named_tuple_test.to_io(io)

      # Deserialize from IO
      io.rewind
      restored_test = NamedTupleTest.from_io(io)

      # Verify named tuples match
      restored_test.simple_named_tuple.should eq named_tuple_test.simple_named_tuple
      restored_test.nested_named_tuple.should eq named_tuple_test.nested_named_tuple
    end

    it "handles named tuple direct serialization" do
      # Create a named tuple
      named_tuple = {id: 42, name: "hello", value: 3.14, active: true}

      # Serialize directly
      io = IO::Memory.new
      named_tuple.to_io(io)

      # Deserialize directly
      io.rewind
      restored_named_tuple = NamedTuple(id: Int32, name: String, value: Float64, active: Bool).from_io(io)

      # Verify named tuple matches
      restored_named_tuple.should eq named_tuple
    end

    it "handles nested named tuples" do
      # Create a nested named tuple
      nested_named_tuple = {info: {label: "nested", count: 99}, score: 123.456}

      # Serialize directly
      io = IO::Memory.new
      nested_named_tuple.to_io(io)

      # Deserialize directly
      io.rewind
      restored_nested = NamedTuple(info: NamedTuple(label: String, count: Int32), score: Float64).from_io(io)

      # Verify nested named tuple matches
      restored_nested.should eq nested_named_tuple
    end

    it "handles nilable named tuple elements" do
      # Create a test class instance with nilable elements in named tuple
      named_tuple_test = NamedTupleTest.new
      named_tuple_test.nilable_named_tuple = {id: 42, name: "test string", value: 3.14, active: true}

      # Serialize to IO
      io = IO::Memory.new
      named_tuple_test.to_io(io)

      # Deserialize from IO
      io.rewind
      restored_test = NamedTupleTest.from_io(io)

      # Verify named tuples match
      restored_test.nilable_named_tuple.should eq named_tuple_test.nilable_named_tuple

      # Test with nil values
      named_tuple_test.nilable_named_tuple = {id: nil, name: "another test", value: nil, active: false}

      io = IO::Memory.new
      named_tuple_test.to_io(io)

      io.rewind
      restored_test = NamedTupleTest.from_io(io)

      restored_test.nilable_named_tuple.should eq named_tuple_test.nilable_named_tuple
    end

    it "handles nilable nested named tuples" do
      # Create a test class instance with nilable nested named tuple
      named_tuple_test = NamedTupleTest.new
      named_tuple_test.nilable_nested_named_tuple = {info: {label: "nested value", count: 123}, score: 45.67}

      # Serialize to IO
      io = IO::Memory.new
      named_tuple_test.to_io(io)

      # Deserialize from IO
      io.rewind
      restored_test = NamedTupleTest.from_io(io)

      # Verify named tuples match
      restored_test.nilable_nested_named_tuple.should eq named_tuple_test.nilable_nested_named_tuple

      # Test with nil values
      named_tuple_test.nilable_nested_named_tuple = {info: nil, score: 98.76}

      io = IO::Memory.new
      named_tuple_test.to_io(io)

      io.rewind
      restored_test = NamedTupleTest.from_io(io)

      restored_test.nilable_nested_named_tuple.should eq named_tuple_test.nilable_nested_named_tuple

      # Test with all nil values
      named_tuple_test.nilable_nested_named_tuple = {info: nil, score: nil}

      io = IO::Memory.new
      named_tuple_test.to_io(io)

      io.rewind
      restored_test = NamedTupleTest.from_io(io)

      restored_test.nilable_nested_named_tuple.should eq named_tuple_test.nilable_nested_named_tuple
    end

    it "handles enum named tuples" do
      # Create a test class instance with enum named tuple
      named_tuple_test = NamedTupleTest.new
      named_tuple_test.enum_named_tuple = {status: NamedTupleTestStatus::Inactive, optional_status: NamedTupleTestStatus::Pending}

      # Serialize to IO
      io = IO::Memory.new
      named_tuple_test.to_io(io)

      # Deserialize from IO
      io.rewind
      restored_test = NamedTupleTest.from_io(io)

      # Verify named tuples match
      restored_test.enum_named_tuple.should eq named_tuple_test.enum_named_tuple

      # Test with nil value for nilable enum
      named_tuple_test.enum_named_tuple = {status: NamedTupleTestStatus::Deleted, optional_status: nil}

      io = IO::Memory.new
      named_tuple_test.to_io(io)

      io.rewind
      restored_test = NamedTupleTest.from_io(io)

      restored_test.enum_named_tuple.should eq named_tuple_test.enum_named_tuple
    end

    it "handles named tuples with serializable class instances" do
      # Create a named tuple with serializable class instances
      address1 = Address.new(street: "123 Main St", city: "Springfield")
      address2 = Address.new(street: "456 Oak Ave", city: "Shelbyville")
      named_tuple = {home: address1, work: address2}

      # Serialize directly
      io = IO::Memory.new
      named_tuple.to_io(io)

      # Deserialize directly
      io.rewind
      restored_named_tuple = NamedTuple(home: Address, work: Address).from_io(io)

      # Verify named tuple matches
      restored_named_tuple[:home].street.should eq "123 Main St"
      restored_named_tuple[:home].city.should eq "Springfield"
      restored_named_tuple[:work].street.should eq "456 Oak Ave"
      restored_named_tuple[:work].city.should eq "Shelbyville"

      # Test with complex nesting: named tuple containing another serializable class with nested named tuple
      composite1 = NamedTupleCompositeTest.new(title: "First", data: {x: 42, y: 3.14})
      composite2 = NamedTupleCompositeTest.new(title: "Second", data: {x: 99, y: 2.71})

      complex_named_tuple = {first: composite1, label: "middle", second: composite2}

      # Serialize
      io = IO::Memory.new
      complex_named_tuple.to_io(io)

      # Deserialize
      io.rewind
      restored_complex = NamedTuple(first: NamedTupleCompositeTest, label: String, second: NamedTupleCompositeTest).from_io(io)

      # Verify
      restored_complex[:first].should eq composite1
      restored_complex[:label].should eq "middle"
      restored_complex[:second].should eq composite2
    end
  end
end
