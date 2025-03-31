# io_serializable v0.3.0

## Overview
This release adds support for named tuple serialization, including nested named tuples, nilable named tuples, and named tuples containing serializable objects.

## New Features

### Named Tuple Serialization
- Added support for all named tuple variants:
  - Simple named tuples of primitive types
  - Nested named tuples (named tuples containing other named tuples)
  - Named tuples with nilable elements
  - Nilable nested named tuples
  - Named tuples containing enum values
  - Named tuples containing serializable class instances
  - Complex nested structures with named tuples containing serializable objects

### Improved Float Serialization
- Comprehensive handling of special float values:
  - Infinity and negative infinity
  - NaN (Not a Number)
  - Minimum and maximum representable values
  - Very small values (near subnormal range)
  - Very large values
  - Subnormal numbers
  - Negative zero (preserving sign bit)
  - Common mathematical constants (π, e, etc.)

### Improved Test Coverage
- Added extensive test suite for all implemented types
- Tests for all edge cases and special values

### Improved Documentation
- Added comprehensive examples for named tuple serialization in README
- Added example code for serializing named tuples with class instances
- Enhanced code documentation

## Usage Examples

```crystal
# Basic named tuple serialization
named_tuple = {id: 42, name: "hello", value: 3.14, active: true}
io = IO::Memory.new
named_tuple.to_io(io)

io.rewind
restored_named_tuple = NamedTuple(id: Int32, name: String, value: Float64, active: Bool).from_io(io)
```

```crystal
# Named tuples with serializable classes
class Point
  include IO::Serializable
  
  property x : Int32
  property y : Int32
  
  def initialize(@x = 0, @y = 0)
  end
end

point_named_tuple = {home: Point.new(x: 10, y: 20), work: Point.new(x: 30, y: 40)}
io = IO::Memory.new
point_named_tuple.to_io(io)

io.rewind
restored_points = NamedTuple(home: Point, work: Point).from_io(io)
```

```crystal
# Basic float serialization
class Point
  include IO::Serializable
  
  property x : Float64
  property y : Float64
  property z : Float32
  
  def initialize(@x = 0.0, @y = 0.0, @z = 0.0_f32)
  end
end

# Create and serialize a point
point = Point.new(x: 10.5, y: 20.75, z: 5.25_f32)
io = IO::Memory.new
point.to_io(io)

# Deserialize the point
io.rewind
restored_point = Point.from_io(io)
```

```crystal
# Handling special float values
class MathValues
  include IO::Serializable
  
  property pi : Float64 = Math::PI
  property e : Float64 = Math::E
  property infinity : Float64 = Float64::INFINITY
  property nan : Float64 = Float64::NAN
  
  def initialize
  end
end

math = MathValues.new
io = IO::Memory.new
math.to_io(io)

io.rewind
restored_math = MathValues.from_io(io)
```

# io_serializable v0.2.0

## Overview
This release adds support for tuple serialization, including nested tuples, nilable tuples, and tuples containing serializable objects.

## New Features

### Tuple Serialization
- Added support for all tuple variants:
  - Simple tuples of primitive types
  - Nested tuples (tuples containing other tuples)
  - Tuples with nilable elements
  - Nilable nested tuples
  - Tuples containing enum values
  - Tuples containing serializable class instances
  - Complex nested structures with tuples containing serializable objects that themselves contain tuples

### Improved Documentation
- Added comprehensive examples for tuple serialization in README
- Added example code for serializing tuples with class instances
- Enhanced code documentation

### Bug Fixes
- Fixed handling of nil values in tuple serialization
- Improved error handling for nilable types

### Other Improvements
- Enhanced test coverage for all tuple variants
- Code optimizations for tuple serialization

## Usage Examples

```crystal
# Basic tuple serialization
tuple = {42, "hello", 3.14, true}
io = IO::Memory.new
tuple.to_io(io)

io.rewind
restored_tuple = Tuple(Int32, String, Float64, Bool).from_io(io)
```

```crystal
# Tuples with serializable classes
class Point
  include IO::Serializable
  
  property x : Int32
  property y : Int32
  
  def initialize(@x = 0, @y = 0)
  end
end

point_tuple = {Point.new(x: 10, y: 20), Point.new(x: 30, y: 40)}
io = IO::Memory.new
point_tuple.to_io(io)

io.rewind
restored_points = Tuple(Point, Point).from_io(io)
```

# io_serializable v0.1.0

## Overview
`io_serializable` is a Crystal library that provides binary serialization and deserialization for Crystal objects. This library extends the IO class to allow objects to be written to and read from binary streams.

## Features

### Core Functionality
- Binary serialization and deserialization of Crystal objects
- Support for both big-endian and little-endian byte formats
- Automatic handling of nilable types
- Support for nested serializable objects

### Supported Types
- Primitive types:
  - Integers: `Int8`, `Int16`, `Int32`, `Int64`, `UInt8`, `UInt16`, `UInt32`, `UInt64`
  - Floating point: `Float32`, `Float64`
  - `Bool`
  - `Char` (including Unicode characters)
  - `String`
- Nilable versions of all primitive types
- Enums
- Nested objects that include `IO::Serializable`

### Field Annotations
- `@[IO::Field(skip: true)]` - Exclude specific fields from serialization
  - Useful for sensitive data (e.g., passwords)
  - Runtime-only fields
  - Temporary data

## Requirements
- Crystal >= 1.15.1

## Installation
Add the dependency to your `shard.yml`:

```yaml
dependencies:
  io_serializable:
    github: dsennerlov/io_serializable
```

## Usage
```crystal
require "io_serializable"

class Person
  include IO::Serializable
  
  property name : String
  property age : Int32
  
  def initialize(@name = "", @age = 0)
  end
end

# Serialize
person = Person.new(name: "Alice", age: 30)
io = IO::Memory.new
person.to_io(io)

# Deserialize
io.rewind
restored_person = Person.from_io(io)
```

## Known Limitations
- `Symbol` type is not supported for serialization
- Arrays are not yet supported (planned for future releases)

## Future Plans
- Add support for Arrays
- Add annotation for ByteFormat
- Additional type support and optimizations

## License
MIT License

## Author
David Sennerlöv <david@sennerlov.se>

This release provides a solid foundation for binary serialization in Crystal, with support for all major primitive types and a clean, intuitive API. The library is production-ready for use cases that don't require array serialization or symbol support. 