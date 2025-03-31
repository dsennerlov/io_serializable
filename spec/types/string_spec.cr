require "spec"
require "../../src/io/serializable"

# Define a class for testing string serialization
class StringTest
  include IO::Serializable

  property standard_string : String
  property nilable_string : String?
  property empty_string : String = ""
  property with_default : String = "default value"
  property! property_bang : String?
  property? property_question : String?

  def initialize(@standard_string = "", @nilable_string = nil, @property_bang = nil, @property_question = nil)
  end

  def ==(other : StringTest)
    standard_string == other.standard_string &&
    nilable_string == other.nilable_string &&
    empty_string == other.empty_string &&
    with_default == other.with_default &&
    property_bang? == other.property_bang? &&
    property_question? == other.property_question?
  end
end

describe IO::Serializable do
  describe "string serialization" do
    it "handles basic string values" do
      test = StringTest.new(standard_string: "Hello world")

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      restored.standard_string.should eq "Hello world"
    end

    it "handles empty strings" do
      test = StringTest.new(standard_string: "")

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      restored.standard_string.should eq ""
      restored.empty_string.should eq ""
    end

    it "handles strings with special characters" do
      special_chars = "Special chars: !@#$%^&*()_+{}💥[]|\\:;\"'<>,.?/"
      test = StringTest.new(standard_string: special_chars)

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      restored.standard_string.should eq special_chars
    end

    it "handles strings with unicode characters" do
      unicode_chars = "Unicode: 你好, こんにちは, 안녕하세요, Привет, مرحبا"
      test = StringTest.new(standard_string: unicode_chars)

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      restored.standard_string.should eq unicode_chars
    end

    it "handles nilable string with non-nil value" do
      test = StringTest.new(nilable_string: "Not nil")

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      restored.nilable_string.should eq "Not nil"
    end

    it "handles nilable string with nil value" do
      test = StringTest.new(nilable_string: nil)

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      restored.nilable_string.should be_nil
    end

    it "handles property! for strings" do
      test = StringTest.new(property_bang: "Bang property")

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      restored.property_bang.should eq "Bang property"

      # Test with nil value
      test = StringTest.new(property_bang: nil)

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      restored.property_bang?.should be_nil
    end

    it "handles property? for strings" do
      test = StringTest.new(property_question: "Question property")

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      restored.property_question?.should eq "Question property"

      # Test with nil value
      test = StringTest.new(property_question: nil)

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      restored.property_question?.should be_nil
    end

    it "handles default values" do
      test = StringTest.new

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      restored.with_default.should eq "default value"
    end

    it "handles direct serialization of string values" do
      str = "Direct string"

      io = IO::Memory.new
      str.to_io(io)
      io.rewind
      restored_str = String.from_io(io)

      restored_str.should eq str
    end

    it "handles string in composite objects" do
      # Create a test instance with various string configurations
      test = StringTest.new(
        standard_string: "Standard",
        nilable_string: "Nilable",
        property_bang: "Bang",
        property_question: "Question"
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      # Verify all fields match
      restored.should eq test
    end
  end
end
