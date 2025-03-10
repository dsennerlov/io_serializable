# io_serializable

A Crystal library that provides binary serialization and deserialization for Crystal objects. This library extends the IO class to allow objects to be written to and read from binary streams.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     io_serializable:
       github: dsennerlov/io_serializable
   ```

2. Run `shards install`

## Usage

```crystal
require "io_serializable"
```

### Basic Usage

Include the `IO::Serializable` module in your class to make it serializable:

```crystal
class Person
  include IO::Serializable
  
  property name : String
  property age : Int32
  property is_active : Bool
  property salary : Float64
  property grade : Char
  property optional_field : String?
  
  def initialize(@name = "", @age = 0, @is_active = false, @salary = 0.0, @grade = 'F', @optional_field = nil)
  end
end
```

#### Serializing to Binary

```crystal
# Create an instance
person = Person.new(
  name: "Alice Cooper",
  age: 30,
  is_active: true,
  salary: 75000.50,
  grade: 'A',
  optional_field: "Some data"
)

# Serialize to a memory buffer
io = IO::Memory.new
person.to_io(io)

# Get the binary data
binary_data = io.to_slice
```

#### Deserializing from Binary

```crystal
# Assuming you have binary data in a buffer
io = IO::Memory.new(binary_data)

# Deserialize back to an object
restored_person = Person.from_io(io)

# Now you can use the restored object
puts restored_person.name # => "Alice Cooper"
```

### Supported Types

The library supports serialization of the following types:

- Primitive types:
  - Integers: `Int8`, `Int16`, `Int32`, `Int64`, `UInt8`, `UInt16`, `UInt32`, `UInt64`
  - Floating point: `Float32`, `Float64`
  - `Bool`
  - `Char`
  - `String`
- Nilable versions of all the above types
- Nested objects that also include `IO::Serializable`

### Nested Objects

You can nest serializable objects:

```crystal
class Address
  include IO::Serializable
  
  property street : String
  property city : String
  
  def initialize(@street = "", @city = "")
  end
end

class Employee
  include IO::Serializable
  
  property name : String
  property address : Address
  property salary : Float64
  
  def initialize(@name = "", @address = Address.new, @salary = 0.0)
  end
end

# Usage
employee = Employee.new(
  name: "John Doe",
  address: Address.new(street: "123 Main St", city: "Anytown"),
  salary: 85000.0
)

# Serialize
io = IO::Memory.new
employee.to_io(io)

# Deserialize
io.rewind
restored_employee = Employee.from_io(io)
```

### Byte Format

You can specify the byte format when serializing:

```crystal
# Use big endian format
io = IO::Memory.new
person.to_io(io, IO::ByteFormat::BigEndian)

# Use little endian format
io = IO::Memory.new
person.to_io(io, IO::ByteFormat::LittleEndian)
```

## TODO

- Add annotiation for BytFormat
- Add support for Arrays
- Add annotation for Skip

## Development

To run the tests:

```
crystal spec
```

## Contributing

1. Fork it (<https://github.com/dsennerlov/io_serializable/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [David Sennerlöv](https://github.com/dsennerlov) - creator and maintainer
