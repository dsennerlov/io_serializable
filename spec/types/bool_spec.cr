require "spec"
require "../../src/io/serializable"

# Define a class for testing boolean serialization
class BoolTest
  include IO::Serializable

  property standard_bool : Bool
  property nilable_bool : Bool?
  property with_default : Bool = true

  def initialize(@standard_bool = false, @nilable_bool = nil)
  end

  def ==(other : BoolTest)
    standard_bool == other.standard_bool &&
    nilable_bool == other.nilable_bool &&
    with_default == other.with_default
  end
end

describe IO::Serializable do
  describe "boolean serialization" do
    it "handles true values" do
      test = BoolTest.new(standard_bool: true)

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = BoolTest.from_io(io)

      restored.standard_bool.should be_true
    end

    it "handles false values" do
      test = BoolTest.new(standard_bool: false)

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = BoolTest.from_io(io)

      restored.standard_bool.should be_false
    end

    it "handles default boolean values" do
      test = BoolTest.new

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = BoolTest.from_io(io)

      restored.standard_bool.should be_false
      restored.with_default.should be_true
    end

    it "handles nilable boolean with non-nil value" do
      test = BoolTest.new(nilable_bool: true)

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = BoolTest.from_io(io)

      restored.nilable_bool.should eq true
    end

    it "handles nilable boolean with nil value" do
      test = BoolTest.new(nilable_bool: nil)

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = BoolTest.from_io(io)

      restored.nilable_bool.should be_nil
    end

    it "handles direct serialization of boolean values" do
      # True value
      io = IO::Memory.new
      true.to_io(io)
      io.rewind
      Bool.from_io(io).should be_true

      # False value
      io = IO::Memory.new
      false.to_io(io)
      io.rewind
      Bool.from_io(io).should be_false
    end

    it "handles boolean in composite objects" do
      # Create a test instance with various boolean configurations
      test = BoolTest.new(
        standard_bool: true,
        nilable_bool: false
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = BoolTest.from_io(io)

      # Verify all fields match
      restored.should eq test
    end
  end
end
