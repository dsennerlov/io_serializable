require "../src/io_serializable"
require "json"

enum Classification
  Senior
  Junior
  Middle
end

# Example class demonstrating IO::Serializable usage
class Person
  include JSON::Serializable
  include IO::Serializable

  property! name : String?
  property classification : Classification = Classification::Middle
  property age : Int32
  property count : Int8
  property items : Int16
  property big_num : Int64
  property small_uint : UInt8
  property medium_uint : UInt16
  property large_uint : UInt32
  property huge_uint : UInt64
  property salary : Float32
  property balance : Float64
  property is_active : Bool
  property grade : Char
  property! nilable_1 : String
  property! nilable_2 : String?
  property? nilable_3 : String?
  property  nilable_4 : String | Nil
  property nilable_int : Int32?
  property nilable_float : Float64?
  property nilable_char : Char? = '🚀'
  property tags : Array(String) = [] of String
  property categories : Array(String)

  def initialize(
    @name = "",
    @age = 10,
    @count = Int8::MAX,
    @items = Int16::MAX,
    @big_num = Int64::MAX,
    @small_uint = UInt8::MAX,
    @medium_uint = UInt16::MAX,
    @large_uint = UInt32::MAX,
    @huge_uint = UInt64::MAX,
    @salary = Float32::MAX,
    @balance = Float64::MAX,
    @is_active = true,
    @grade = '👍',
    @tags = ["tag1", "tag2"],
    @categories = [] of String,
  )
  end

  # Example of what the macro generates (simplified)
  def example_to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
    io.write_bytes(@name.nil? ? 1_i8 : 0_i8, format)
    unless @name.nil?
      io.write_bytes(@name.not_nil!.bytesize, format)
      io.write(@name.not_nil!.to_slice)
    end

    io.write_bytes(@age, format)
    io.write_bytes(@count, format)
    io.write_bytes(@items, format)
    io.write_bytes(@big_num, format)
    io.write_bytes(@small_uint, format)
    io.write_bytes(@medium_uint, format)
    io.write_bytes(@large_uint, format)
    io.write_bytes(@huge_uint, format)
    io.write_bytes(@salary, format)
    io.write_bytes(@balance, format)
    io.write_bytes(@is_active ? 1_i8 : 0_i8, format)
    io.write_bytes(@grade, format)

    char_bytes = @grade.to_s.bytes
    padding = 4 - char_bytes.size
    padding.times { io.write_bytes(0_u8, format) }
    char_bytes.each { |byte| io.write_bytes(byte, format) }

    [@nilable_1, @nilable_2, @nilable_3, @nilable_4].each do |str|
      io.write_bytes(str.nil? ? 1_i8 : 0_i8, format)
      unless str.nil?
        io.write_bytes(str.bytesize, format)
        io.write(str.to_slice)
      end
    end
  end

  def ==(other : Person)
    name == other.name &&
    age == other.age &&
    count == other.count &&
    items == other.items &&
    big_num == other.big_num &&
    small_uint == other.small_uint &&
    medium_uint == other.medium_uint &&
    large_uint == other.large_uint &&
    huge_uint == other.huge_uint &&
    salary == other.salary &&
    balance == other.balance &&
    is_active == other.is_active &&
    # grade == other.grade &&
    nilable_1? == other.nilable_1? &&
    nilable_2? == other.nilable_2? &&
    nilable_3? == other.nilable_3? &&
    nilable_4 == other.nilable_4
  end
end

# Create a person object
person = Person.new(name: "Alice Cooper", age: 30, salary: 102030.0)
puts "Original person: #{person.name}, #{person.age}, #{person.salary}"

# person.nilable_1 = "Hello"
puts "person.nilable_1? #{person.nilable_1?}"

io = IO::Memory.new
person.to_io(io)

puts "Serialized to IO (size: #{io.size} bytes)"
puts "Debug - IO contents: #{io.to_slice.inspect}"

# Deserialize from IO
io.rewind
restored_person = Person.from_io(io)
puts "Deserialized person: #{restored_person.name}, #{restored_person.age}" #", #{restored_person.grade}"
pp restored_person

puts "Objects match: #{person == restored_person}"

# More complex example with nested objects
class Address
  include IO::Serializable

  property street : String
  property city : String

  def initialize(@street = "", @city = "")
  end

  def ==(other : Address)
    street == other.street &&
    city == other.city
  end
end

class Employee
  include IO::Serializable

  property name : String
  property address : Address
  property salary : Float64

  def initialize(@name = "", @address = Address.new, @salary = 0.0)
  end

  def ==(other : Employee)
    name == other.name &&
    address == other.address &&
    salary == other.salary
  end
end

# Create a complex object
employee = Employee.new(
  name: "Bob",
  address: Address.new(street: "123 Main St", city: "Anytown"),
  salary: 75000.50
)

puts "\nOriginal employee: #{employee.name}, #{employee.address.city}, $#{employee.salary}"

# Serialize and deserialize
io = IO::Memory.new
employee.to_io(io)
puts "Debug - IO contents: #{io.to_slice.inspect}"

io.rewind
restored_employee = Employee.from_io(io)

puts "Deserialized employee: #{restored_employee.name}, #{restored_employee.address.city}, $#{restored_employee.salary}"

puts "Objects match: #{employee == restored_employee}"
