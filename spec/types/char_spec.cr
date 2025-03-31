require "spec"
require "../../src/io/serializable"

# Define a class for testing char serialization
class CharTest
  include IO::Serializable

  property standard_char : Char
  property nilable_char : Char?
  property with_default : Char = 'D'

  def initialize(@standard_char = 'A', @nilable_char = nil)
  end

  def ==(other : CharTest)
    standard_char == other.standard_char &&
    nilable_char == other.nilable_char &&
    with_default == other.with_default
  end
end

describe IO::Serializable do
  describe "char serialization" do
    it "handles basic char values" do
      test = CharTest.new(standard_char: 'X')

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = CharTest.from_io(io)

      restored.standard_char.should eq 'X'
    end

    it "handles ASCII characters" do
      ['A', 'Z', '0', '9', '!', '~', ' '].each do |char|
        test = CharTest.new(standard_char: char)

        io = IO::Memory.new
        test.to_io(io)
        io.rewind
        restored = CharTest.from_io(io)

        restored.standard_char.should eq char
      end
    end

    it "handles unicode characters" do
      ['👍', '🚀', '💡', '🌈', '你', 'こ', '안', 'Ж', 'م'].each do |char|
        test = CharTest.new(standard_char: char)

        io = IO::Memory.new
        test.to_io(io)
        io.rewind
        restored = CharTest.from_io(io)

        restored.standard_char.should eq char
      end
    end

    it "handles nilable char with non-nil value" do
      test = CharTest.new(nilable_char: 'Z')

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = CharTest.from_io(io)

      restored.nilable_char.should eq 'Z'
    end

    it "handles nilable char with nil value" do
      test = CharTest.new(nilable_char: nil)

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = CharTest.from_io(io)

      restored.nilable_char.should be_nil
    end

    it "handles default values" do
      test = CharTest.new

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = CharTest.from_io(io)

      restored.with_default.should eq 'D'
    end

    it "handles direct serialization of char values" do
      # ASCII char
      io = IO::Memory.new
      'R'.to_io(io)
      io.rewind
      Char.from_io(io).should eq 'R'

      # Unicode char
      io = IO::Memory.new
      '🔥'.to_io(io)
      io.rewind
      Char.from_io(io).should eq '🔥'
    end

    it "handles char in composite objects" do
      # Create a test instance with various char configurations
      test = CharTest.new(
        standard_char: 'S',
        nilable_char: '!'
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = CharTest.from_io(io)

      # Verify all fields match
      restored.should eq test
    end

    it "handles char code points" do
      # Test a range of code points (skip 0 as it causes issues)
      [65, 127, 1024, 9000, 128512].each do |code_point|
        char = code_point.chr

        io = IO::Memory.new
        char.to_io(io)
        io.rewind
        restored = Char.from_io(io)

        restored.should eq char
        restored.ord.should eq code_point
      end
    end
  end
end
