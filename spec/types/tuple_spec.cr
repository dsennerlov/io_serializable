require "spec"
require "../../src/io/serializable"

# Define an enum for testing
enum TupleTestStatus
  Active = 1
  Inactive = 2
  Pending = 3
  Deleted = 4
end

# Define a class for testing tuple serialization
class TupleTest
  include IO::Serializable

  property simple_tuple : Tuple(Int32, String, Float64, Bool) = {0, "", 0.0, false}
  property nested_tuple : Tuple(Tuple(String, Int32), Float64) = { {"", 0}, 0.0}
  property nilable_tuple : Tuple(Int32?, String, Float64?, Bool) = {nil, "", nil, false}
  property nilable_nested_tuple : Tuple(Tuple(String, Int32)?, Float64?) = {nil, nil}
  property enum_tuple : Tuple(TupleTestStatus, TupleTestStatus?) = {TupleTestStatus::Active, nil}

  def initialize
  end
end

# Define a class for testing composite tuple serialization
class CompositeTest
  include IO::Serializable

  property name : String
  property data_tuple : Tuple(Int32, Float64)

  def initialize(@name = "", @data_tuple = {0, 0.0})
  end

  def ==(other : CompositeTest)
    name == other.name && data_tuple == other.data_tuple
  end
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

describe IO::Serializable do
  describe "tuple serialization" do
    it "serializes and deserializes tuple properties" do
      # Create a test class instance with tuple property
      tuple_test = TupleTest.new
      tuple_test.simple_tuple = {42, "hello", 3.14, true}
      tuple_test.nested_tuple = { {"nested", 99}, 123.456}

      # Serialize to IO
      io = IO::Memory.new
      tuple_test.to_io(io)

      # Deserialize from IO
      io.rewind
      restored_test = TupleTest.from_io(io)

      # Verify tuples match
      restored_test.simple_tuple.should eq tuple_test.simple_tuple
      restored_test.nested_tuple.should eq tuple_test.nested_tuple
    end

    it "handles tuple direct serialization" do
      # Create a tuple
      tuple = {42, "hello", 3.14, true}

      # Serialize directly
      io = IO::Memory.new
      tuple.to_io(io)

      # Deserialize directly
      io.rewind
      restored_tuple = Tuple(Int32, String, Float64, Bool).from_io(io)

      # Verify tuple matches
      restored_tuple.should eq tuple
    end

    it "handles nested tuples" do
      # Create a nested tuple
      nested_tuple = { {"nested", 99}, 123.456}

      # Serialize directly
      io = IO::Memory.new
      nested_tuple.to_io(io)

      # Deserialize directly
      io.rewind
      restored_nested = Tuple(Tuple(String, Int32), Float64).from_io(io)

      # Verify nested tuple matches
      restored_nested.should eq nested_tuple
    end

    it "handles nilable tuple elements" do
      # Create a test class instance with nilable elements in tuple
      tuple_test = TupleTest.new
      tuple_test.nilable_tuple = {42, "test string", 3.14, true}

      # Serialize to IO
      io = IO::Memory.new
      tuple_test.to_io(io)

      # Deserialize from IO
      io.rewind
      restored_test = TupleTest.from_io(io)

      # Verify tuples match
      restored_test.nilable_tuple.should eq tuple_test.nilable_tuple

      # Test with nil values
      tuple_test.nilable_tuple = {nil, "another test", nil, false}

      io = IO::Memory.new
      tuple_test.to_io(io)

      io.rewind
      restored_test = TupleTest.from_io(io)

      restored_test.nilable_tuple.should eq tuple_test.nilable_tuple
    end

    it "handles nilable nested tuples" do
      # Create a test class instance with nilable nested tuple
      tuple_test = TupleTest.new
      tuple_test.nilable_nested_tuple = { {"nested value", 123}, 45.67}

      # Serialize to IO
      io = IO::Memory.new
      tuple_test.to_io(io)

      # Deserialize from IO
      io.rewind
      restored_test = TupleTest.from_io(io)

      # Verify tuples match
      restored_test.nilable_nested_tuple.should eq tuple_test.nilable_nested_tuple

      # Test with nil values
      tuple_test.nilable_nested_tuple = {nil, 98.76}

      io = IO::Memory.new
      tuple_test.to_io(io)

      io.rewind
      restored_test = TupleTest.from_io(io)

      restored_test.nilable_nested_tuple.should eq tuple_test.nilable_nested_tuple

      # Test with all nil values
      tuple_test.nilable_nested_tuple = {nil, nil}

      io = IO::Memory.new
      tuple_test.to_io(io)

      io.rewind
      restored_test = TupleTest.from_io(io)

      restored_test.nilable_nested_tuple.should eq tuple_test.nilable_nested_tuple
    end

    it "handles enum tuples" do
      # Create a test class instance with enum tuple
      tuple_test = TupleTest.new
      tuple_test.enum_tuple = {TupleTestStatus::Inactive, TupleTestStatus::Pending}

      # Serialize to IO
      io = IO::Memory.new
      tuple_test.to_io(io)

      # Deserialize from IO
      io.rewind
      restored_test = TupleTest.from_io(io)

      # Verify tuples match
      restored_test.enum_tuple.should eq tuple_test.enum_tuple

      # Test with nil value for nilable enum
      tuple_test.enum_tuple = {TupleTestStatus::Deleted, nil}

      io = IO::Memory.new
      tuple_test.to_io(io)

      io.rewind
      restored_test = TupleTest.from_io(io)

      restored_test.enum_tuple.should eq tuple_test.enum_tuple
    end

    it "handles tuples with serializable class instances" do
      # Create a tuple with serializable class instances
      address1 = Address.new(street: "123 Main St", city: "Springfield")
      address2 = Address.new(street: "456 Oak Ave", city: "Shelbyville")
      tuple = {address1, address2}

      # Serialize directly
      io = IO::Memory.new
      tuple.to_io(io)

      # Deserialize directly
      io.rewind
      restored_tuple = Tuple(Address, Address).from_io(io)

      # Verify tuple matches
      restored_tuple[0].street.should eq "123 Main St"
      restored_tuple[0].city.should eq "Springfield"
      restored_tuple[1].street.should eq "456 Oak Ave"
      restored_tuple[1].city.should eq "Shelbyville"

      # Test with complex nesting: tuple containing another serializable class with nested tuple
      composite1 = CompositeTest.new(name: "First", data_tuple: {42, 3.14})
      composite2 = CompositeTest.new(name: "Second", data_tuple: {99, 2.71})

      complex_tuple = {composite1, "middle", composite2}

      # Serialize
      io = IO::Memory.new
      complex_tuple.to_io(io)

      # Deserialize
      io.rewind
      restored_complex = Tuple(CompositeTest, String, CompositeTest).from_io(io)

      # Verify
      restored_complex[0].should eq composite1
      restored_complex[1].should eq "middle"
      restored_complex[2].should eq composite2
    end
  end
end
