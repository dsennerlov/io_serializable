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