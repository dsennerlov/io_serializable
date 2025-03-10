require "spec"
require "../src/io/serializable"

macro define_type_class(name, type, default)
  class {{name}}
    include IO::Serializable

    property value : {{type}}? = {{default}}

    def initialize(@value = nil); end
  end
end

define_type_class(StringType, String, "Hello, world!")
define_type_class(Int8Type, Int8, 100_i8)
define_type_class(Int16Type, Int16, 1000_i16)
define_type_class(Int32Type, Int32, 1000000_i32)
define_type_class(Int64Type, Int64, 1000000000_i64)
define_type_class(UInt8Type, UInt8, 200_u8)
define_type_class(UInt16Type, UInt16, 40000_u16)
define_type_class(UInt32Type, UInt32, 3000000000_u32)
define_type_class(UInt64Type, UInt64, 10000000000000_000_000_u64)
define_type_class(Float32Type, Float32, 102030.5_f32)
define_type_class(Float64Type, Float64, 9876543.21_f64)
define_type_class(BoolType, Bool, true)


macro it_behaves_like_io_serializable(class_name)
  it "serializes and deserializes" do
    type = {{class_name.id}}.new
    io = IO::Memory.new
    type.to_io(io)

    io.rewind
    restored_type = {{class_name.id}}.from_io(io)
    restored_type.value.should eq type.value
  end
end

describe "Types" do
  it_behaves_like_io_serializable(StringType)
  it_behaves_like_io_serializable(Int8Type)
  it_behaves_like_io_serializable(Int16Type)
  it_behaves_like_io_serializable(Int32Type)
  it_behaves_like_io_serializable(Int64Type)
  it_behaves_like_io_serializable(UInt8Type)
  it_behaves_like_io_serializable(UInt16Type)
  it_behaves_like_io_serializable(UInt32Type)
  it_behaves_like_io_serializable(UInt64Type)
  it_behaves_like_io_serializable(Float32Type)
  it_behaves_like_io_serializable(Float64Type)
  it_behaves_like_io_serializable(BoolType)
end
