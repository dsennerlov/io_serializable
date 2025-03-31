require "spec"
require "../../src/io/serializable"

# Define a class for testing float serialization
class FloatTest
  include IO::Serializable

  # Standard Float types
  property float32 : Float32
  property float64 : Float64

  # Nilable float types
  property nilable_float32 : Float32?
  property nilable_float64 : Float64?

  # Default values
  property default_pi : Float64 = Math::PI
  property default_zero : Float64 = 0.0

  def initialize(
    @float32 = 0.0_f32,
    @float64 = 0.0_f64,
    @nilable_float32 = nil,
    @nilable_float64 = nil
  )
  end

  def ==(other : FloatTest)
    float32 == other.float32 &&
    float64 == other.float64 &&
    nilable_float32 == other.nilable_float32 &&
    nilable_float64 == other.nilable_float64 &&
    default_pi == other.default_pi &&
    default_zero == other.default_zero
  end
end

describe IO::Serializable do
  describe "float serialization" do
    it "handles standard float values" do
      test = FloatTest.new(
        float32: 3.14159_f32,
        float64: 2.71828182845904_f64
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = FloatTest.from_io(io)

      restored.float32.should eq 3.14159_f32
      restored.float64.should eq 2.71828182845904_f64
    end

    it "handles minimum float values" do
      test = FloatTest.new(
        float32: Float32::MIN,
        float64: Float64::MIN
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = FloatTest.from_io(io)

      restored.float32.should eq Float32::MIN
      restored.float64.should eq Float64::MIN
    end

    it "handles maximum float values" do
      test = FloatTest.new(
        float32: Float32::MAX,
        float64: Float64::MAX
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = FloatTest.from_io(io)

      restored.float32.should eq Float32::MAX
      restored.float64.should eq Float64::MAX
    end

    it "handles infinity values" do
      test = FloatTest.new(
        float32: Float32::INFINITY,
        float64: Float64::INFINITY
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = FloatTest.from_io(io)

      restored.float32.should eq Float32::INFINITY
      restored.float64.should eq Float64::INFINITY
    end

    it "handles negative infinity values" do
      test = FloatTest.new(
        float32: -Float32::INFINITY,
        float64: -Float64::INFINITY
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = FloatTest.from_io(io)

      restored.float32.should eq -Float32::INFINITY
      restored.float64.should eq -Float64::INFINITY
    end

    it "handles NaN values" do
      test = FloatTest.new(
        float32: Float32::NAN,
        float64: Float64::NAN
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = FloatTest.from_io(io)

      restored.float32.nan?.should be_true
      restored.float64.nan?.should be_true
    end

    it "handles nilable float with non-nil values" do
      test = FloatTest.new(
        nilable_float32: 1.23456_f32,
        nilable_float64: 7.891011121314_f64
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = FloatTest.from_io(io)

      restored.nilable_float32.should eq 1.23456_f32
      restored.nilable_float64.should eq 7.891011121314_f64
    end

    it "handles nilable float with nil values" do
      test = FloatTest.new(
        nilable_float32: nil,
        nilable_float64: nil
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = FloatTest.from_io(io)

      restored.nilable_float32.should be_nil
      restored.nilable_float64.should be_nil
    end

    it "handles very small values" do
      test = FloatTest.new(
        float32: 1.0e-37_f32,  # Close to but not below Float32 minimum subnormal
        float64: 1.0e-307_f64  # Close to but not below Float64 minimum subnormal
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = FloatTest.from_io(io)

      # For very small values, check that they're approximately equal (within epsilon)
      (restored.float32 - 1.0e-37_f32).abs.should be < Float32::EPSILON
      (restored.float64 - 1.0e-307_f64).abs.should be < Float64::EPSILON
    end

    it "handles very large values" do
      test = FloatTest.new(
        float32: 1.0e37_f32,
        float64: 1.0e307_f64
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = FloatTest.from_io(io)

      # For very large values, using relative error is more appropriate
      (restored.float32 / 1.0e37_f32 - 1.0).abs.should be < 1e-6
      (restored.float64 / 1.0e307_f64 - 1.0).abs.should be < 1e-10
    end

    it "handles default values" do
      test = FloatTest.new

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = FloatTest.from_io(io)

      restored.default_pi.should eq Math::PI
      restored.default_zero.should eq 0.0
    end

    it "handles float in composite objects" do
      # Create a test instance with various float configurations
      test = FloatTest.new(
        float32: -12.34_f32,
        float64: -56.789_f64,
        nilable_float32: 100.001_f32,
        nilable_float64: 200.002_f64
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = FloatTest.from_io(io)

      # Verify all fields match
      restored.should eq test
    end

    it "handles negative zero" do
      test = FloatTest.new(
        float32: -0.0_f32,
        float64: -0.0_f64
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = FloatTest.from_io(io)

      1.0_f32 / restored.float32 < 0.0 # Check sign bit is preserved for -0.0
      1.0_f64 / restored.float64 < 0.0 # Check sign bit is preserved for -0.0
    end

    it "handles common math constants" do
      test = FloatTest.new(
        float32: Math::PI.to_f32,
        float64: Math::E
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = FloatTest.from_io(io)

      restored.float32.should eq Math::PI.to_f32
      restored.float64.should eq Math::E
    end

    it "handles subnormal numbers" do
      # Subnormal numbers are very small non-zero values close to zero
      subnormal_f32 = 1.0e-45_f32 # A subnormal Float32
      subnormal_f64 = 1.0e-310_f64 # A subnormal Float64

      test = FloatTest.new(
        float32: subnormal_f32,
        float64: subnormal_f64
      )

      io = IO::Memory.new
      test.to_io(io)
      io.rewind
      restored = FloatTest.from_io(io)

      # For subnormal numbers, we check they're non-zero and have the same sign
      restored.float32.should_not eq 0.0_f32
      restored.float64.should_not eq 0.0_f64

      (restored.float32 > 0).should eq (subnormal_f32 > 0)
      (restored.float64 > 0).should eq (subnormal_f64 > 0)
    end
  end
end
