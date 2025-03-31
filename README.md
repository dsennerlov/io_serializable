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
- `Tuple` types, including nested and nilable tuples
- `Enum` types, including nilable enums

> **Note:** `Symbol` type is not supported for serialization due to limitations in Crystal's Symbol handling.

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

### Tuples

The library supports serialization of tuples, including nested and nilable tuples:

```crystal
class TupleExample
  include IO::Serializable
  
  property simple_tuple : Tuple(Int32, String, Float64, Bool)
  property nested_tuple : Tuple(Tuple(String, Int32), Float64)
  property nilable_tuple : Tuple(Int32?, String, Float64?, Bool)
  property nilable_nested_tuple : Tuple(Tuple(String, Int32)?, Float64?)
  
  def initialize(
    @simple_tuple = {0, "", 0.0, false},
    @nested_tuple = { {"", 0}, 0.0},
    @nilable_tuple = {nil, "", nil, false},
    @nilable_nested_tuple = {nil, nil}
  )
  end
end

# Create an example instance
example = TupleExample.new(
  simple_tuple: {42, "hello", 3.14, true},
  nested_tuple: { {"nested", 99}, 123.456},
  nilable_tuple: {10, "test", 2.71, false},
  nilable_nested_tuple: { {"inner", 5}, 9.8}
)

# Serialize
io = IO::Memory.new
example.to_io(io)

# Deserialize
io.rewind
restored = TupleExample.from_io(io)

# Verify
puts restored.simple_tuple # => {42, "hello", 3.14, true}
puts restored.nested_tuple # => {{"nested", 99}, 123.456}
```

You can also directly serialize and deserialize tuples:

```crystal
# Create a tuple
tuple = {42, "hello", 3.14, true}

# Serialize
io = IO::Memory.new
tuple.to_io(io)

# Deserialize
io.rewind
restored_tuple = Tuple(Int32, String, Float64, Bool).from_io(io)

puts restored_tuple # => {42, "hello", 3.14, true}
```

Tuples can also contain serializable class instances:

```crystal
# Define serializable classes
class Point
  include IO::Serializable
  
  property x : Int32
  property y : Int32
  
  def initialize(@x = 0, @y = 0)
  end
end

# Create a tuple with serializable objects
point1 = Point.new(x: 10, y: 20)
point2 = Point.new(x: 30, y: 40)
point_tuple = {point1, point2}

# Serialize
io = IO::Memory.new
point_tuple.to_io(io)

# Deserialize
io.rewind
restored_points = Tuple(Point, Point).from_io(io)

puts restored_points[0].x # => 10
puts restored_points[1].y # => 40
```

You can create complex nested structures with tuples containing serializable objects that themselves contain tuples:

```crystal
class DataContainer
  include IO::Serializable
  
  property name : String
  property values : Tuple(Int32, Float64)
  
  def initialize(@name = "", @values = {0, 0.0})
  end
end

# Create a complex nested structure
container = DataContainer.new(name: "Example", values: {42, 3.14})
complex_tuple = {container, "middle", 100}

# Serialize and deserialize
io = IO::Memory.new
complex_tuple.to_io(io)

io.rewind
restored = Tuple(DataContainer, String, Int32).from_io(io)

puts restored[0].name # => "Example"
puts restored[0].values # => {42, 3.14}
puts restored[1] # => "middle"
puts restored[2] # => 100
```

### File I/O

You can write serialized objects directly to files and read them back:

```crystal
class Product
  include IO::Serializable
  
  property id : Int32
  property name : String
  property price : Float64
  property is_available : Bool
  property category : String?
  
  def initialize(
    @id = 0,
    @name = "",
    @price = 0.0,
    @is_available = false,
    @category = nil
  )
  end
end

# Create a product
product = Product.new(
  id: 123,
  name: "Crystal Programming Guide",
  price: 29.99,
  is_available: true,
  category: "Programming"
)

# Write to file
File.open("product.bin", "wb") do |file|
  product.to_io(file)
end

# Read from file
restored_product = File.open("product.bin", "rb") do |file|
  Product.from_io(file)
end

# Verify the data
puts restored_product.name # => "Crystal Programming Guide"
puts restored_product.price # => 29.99

# Clean up
File.delete("product.bin")
```

Note: Always use binary mode (`"wb"` for writing, `"rb"` for reading) when working with serialized data.

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

### Field Annotations

#### Skip Annotation

You can use the `IO::Field` annotation with the `skip` option to exclude specific fields from serialization:

```crystal
class User
  include IO::Serializable
  
  property id : Int32
  property username : String
  property email : String
  
  # This field will be excluded from serialization
  @[IO::Field(skip: true)]
  property password : String
  
  # This field will be excluded from serialization
  @[IO::Field(skip: true)]
  property temporary_token : String?
  
  def initialize(@id = 0, @username = "", @email = "", @password = "", @temporary_token = nil)
  end
end

# Usage
user = User.new(
  id: 1,
  username: "johndoe",
  email: "john@example.com",
  password: "secret123",
  temporary_token: "temp-token-xyz"
)

# Serialize - password and temporary_token will be skipped
io = IO::Memory.new
user.to_io(io)

# Deserialize - password and temporary_token will retain their default values
io.rewind
restored_user = User.from_io(io)
puts restored_user.password # => ""
puts restored_user.temporary_token # => nil
```

This is useful for:
- Excluding sensitive data (like passwords) from serialization
- Skipping temporary or runtime-only fields that shouldn't be persisted
- Optimizing the binary size by excluding unnecessary fields

## TODO

- Add annotiation for BytFormat
- Add support for Arrays

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
