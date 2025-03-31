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
  property large_string : String = "a" * 1000
  property unicode_heavy : String = "🔥🌈🚀" * 100

  def initialize(@standard_string = "", @nilable_string = nil, @property_bang = nil, @property_question = nil)
  end

  def ==(other : StringTest)
    standard_string == other.standard_string &&
    nilable_string == other.nilable_string &&
    empty_string == other.empty_string &&
    with_default == other.with_default &&
    property_bang? == other.property_bang? &&
    property_question? == other.property_question? &&
    large_string == other.large_string &&
    unicode_heavy == other.unicode_heavy
  end
end

# Define a class with multiple string fields of the same type
class MultiStringTest
  include IO::Serializable

  property field1 : String
  property field2 : String
  property field3 : String
  property field4 : String

  def initialize(@field1 = "", @field2 = "", @field3 = "", @field4 = "")
  end

  def ==(other : MultiStringTest)
    field1 == other.field1 &&
    field2 == other.field2 &&
    field3 == other.field3 &&
    field4 == other.field4
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

    it "handles large strings" do
      # Create a large string
      large = "x" * 10000
      test = StringTest.new(standard_string: large)

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      restored.standard_string.should eq large
    end

    it "handles strings with newlines and tabs" do
      multiline = "Line 1\nLine 2\n\tIndented line\nLine with\ttabs"
      test = StringTest.new(standard_string: multiline)

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      restored.standard_string.should eq multiline
    end

    it "handles strings with null bytes" do
      null_string = "String with\0null\0bytes"
      test = StringTest.new(standard_string: null_string)

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      restored.standard_string.should eq null_string
    end

    it "preserves string encoding" do
      test = StringTest.new(standard_string: "你好, こんにちは, 안녕하세요")

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      restored.standard_string.bytesize.should eq test.standard_string.bytesize
      restored.standard_string.should eq test.standard_string
    end

    it "handles multiple string fields" do
      test = MultiStringTest.new(
        field1: "First field",
        field2: "Second field with special chars: !@#$%",
        field3: "Third field with unicode: 你好",
        field4: "Fourth field with \n newlines and \t tabs"
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = MultiStringTest.from_io(io)

      restored.field1.should eq test.field1
      restored.field2.should eq test.field2
      restored.field3.should eq test.field3
      restored.field4.should eq test.field4
    end

    it "handles complex emoji sequences" do
      # Complex emoji with skin tones and ZWJs
      complex_emoji = "👨‍👩‍👧‍👦 👩🏽‍💻 👨🏿‍🦱 🏳️‍🌈 🏳️‍⚧️"
      test = StringTest.new(standard_string: complex_emoji)

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      restored.standard_string.should eq complex_emoji
    end

    it "handles emoji-heavy strings" do
      test = StringTest.new

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = StringTest.from_io(io)

      restored.unicode_heavy.should eq test.unicode_heavy
    end
  end
end
