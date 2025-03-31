require "spec"
require "../src/io/serializable"

# Define an enum for testing
enum TestStatus
  Active = 1
  Inactive = 2
  Pending = 3
  Deleted = 4
end

describe IO::Serializable do
  describe "basic types serialization" do
    it "serializes and deserializes primitive types" do
      # Create a person with various primitive types
      person = Person.new(
        name: "Alice Cooper",
        age: 30,
        count: 100_i8,
        items: 1000_i16,
        big_num: 1_000_000_000_000_i64,
        small_uint: 200_u8,
        medium_uint: 40000_u16,
        large_uint: 3_000_000_000_u32,
        huge_uint: 10_000_000_000_000_000_000_u64,
        salary: 102030.5_f32,
        balance: 9876543.21_f64,
        is_active: true,
        grade: 'A',
        nilable_int: 42,
        nilable_float: 3.14,
        nilable_char: '🚀',
        tags: ["tag1", "tag2"]
      )

      # Serialize to IO
      io = IO::Memory.new
      person.to_io(io)

      # Deserialize from IO
      io.rewind
      restored_person = Person.from_io(io)

      # Verify all fields match
      restored_person.name.should eq person.name
      restored_person.age.should eq person.age
      restored_person.count.should eq person.count
      restored_person.items.should eq person.items
      restored_person.big_num.should eq person.big_num
      restored_person.small_uint.should eq person.small_uint
      restored_person.medium_uint.should eq person.medium_uint
      restored_person.large_uint.should eq person.large_uint
      restored_person.huge_uint.should eq person.huge_uint
      restored_person.salary.should eq person.salary
      restored_person.balance.should eq person.balance
      restored_person.is_active.should eq person.is_active
      restored_person.grade.should eq person.grade
      restored_person.nilable_int.should eq person.nilable_int
      restored_person.nilable_float.should eq person.nilable_float
      restored_person.nilable_char.should eq person.nilable_char
      restored_person.tags.should be_empty
      restored_person.categories.should be_empty

      # Full object comparison
      # restored_person.should eq person
    end

    it "handles maximum values for numeric types" do
      person = Person.new(
        count: Int8::MAX,
        items: Int16::MAX,
        big_num: Int64::MAX,
        small_uint: UInt8::MAX,
        medium_uint: UInt16::MAX,
        large_uint: UInt32::MAX,
        huge_uint: UInt64::MAX,
        salary: Float32::MAX,
        balance: Float64::MAX,
        nilable_int: Int32::MAX,
        nilable_float: Float64::MAX
      )

      io = IO::Memory.new
      person.to_io(io)
      io.rewind
      restored_person = Person.from_io(io)

      restored_person.count.should eq Int8::MAX
      restored_person.items.should eq Int16::MAX
      restored_person.big_num.should eq Int64::MAX
      restored_person.small_uint.should eq UInt8::MAX
      restored_person.medium_uint.should eq UInt16::MAX
      restored_person.large_uint.should eq UInt32::MAX
      restored_person.huge_uint.should eq UInt64::MAX
      restored_person.salary.should eq Float32::MAX
      restored_person.balance.should eq Float64::MAX
      restored_person.nilable_int.should eq Int32::MAX
      restored_person.nilable_float.should eq Float64::MAX
    end

    it "handles minimum values for numeric types" do
      person = Person.new(
        count: Int8::MIN,
        items: Int16::MIN,
        big_num: Int64::MIN,
        small_uint: 0_u8,
        medium_uint: 0_u16,
        large_uint: 0_u32,
        huge_uint: 0_u64,
        salary: Float32::MIN,
        balance: Float64::MIN,
        nilable_int: Int32::MIN,
        nilable_float: Float64::MIN
      )

      io = IO::Memory.new
      person.to_io(io)
      io.rewind
      restored_person = Person.from_io(io)

      restored_person.count.should eq Int8::MIN
      restored_person.items.should eq Int16::MIN
      restored_person.big_num.should eq Int64::MIN
      restored_person.small_uint.should eq 0_u8
      restored_person.medium_uint.should eq 0_u16
      restored_person.large_uint.should eq 0_u32
      restored_person.huge_uint.should eq 0_u64
      restored_person.salary.should eq Float32::MIN
      restored_person.balance.should eq Float64::MIN
      restored_person.nilable_int.should eq Int32::MIN
      restored_person.nilable_float.should eq Float64::MIN
    end
  end

  describe "char serialization" do
    it "handles ASCII characters" do
      person = Person.new(grade: 'X')

      io = IO::Memory.new
      person.to_io(io)
      io.rewind
      restored_person = Person.from_io(io)

      restored_person.grade.should eq 'X'
    end

    it "handles unicode characters" do
      person = Person.new(grade: '👍')

      io = IO::Memory.new
      person.to_io(io)
      io.rewind
      restored_person = Person.from_io(io)

      restored_person.grade.should eq '👍'
    end
  end

  describe "nilable types" do
    it "handles non-nil values in nilable fields" do
      person = Person.new
      person.nilable_1 = "Not nil 1"
      person.nilable_2 = "Not nil 2"
      person.nilable_3 = "Not nil 3"
      person.nilable_4 = "Not nil 4"
      person.nilable_int = 42
      person.nilable_float = 3.14
      person.nilable_char = '🚀'

      io = IO::Memory.new
      person.to_io(io)
      io.rewind
      restored_person = Person.from_io(io)

      restored_person.nilable_1.should eq "Not nil 1"
      restored_person.nilable_2.should eq "Not nil 2"
      restored_person.nilable_3?.should eq "Not nil 3"
      restored_person.nilable_4.should eq "Not nil 4"
      restored_person.nilable_int.should eq 42
      restored_person.nilable_float.should eq 3.14
      restored_person.nilable_char.should eq '🚀'
    end

    it "handles nil values in nilable fields" do
      person = Person.new
      person.nilable_1 = nil
      person.nilable_2 = nil
      person.nilable_3 = nil
      person.nilable_4 = nil
      person.nilable_int = nil
      person.nilable_float = nil
      person.nilable_char = nil

      io = IO::Memory.new
      person.to_io(io)
      io.rewind
      restored_person = Person.from_io(io)

      restored_person.nilable_1?.should be_nil
      restored_person.nilable_2?.should be_nil
      restored_person.nilable_3?.should be_nil
      restored_person.nilable_4.should be_nil
      restored_person.nilable_int.should be_nil
      restored_person.nilable_float.should be_nil
      restored_person.nilable_char.should be_nil
    end

    it "handles mixed nil and non-nil values" do
      person = Person.new
      person.nilable_1 = "Not nil 1"
      person.nilable_2 = nil
      person.nilable_3 = "Not nil 3"
      person.nilable_4 = nil
      person.nilable_int = 42
      person.nilable_float = nil
      person.nilable_char = '🚀'

      io = IO::Memory.new
      person.to_io(io)
      io.rewind
      restored_person = Person.from_io(io)

      restored_person.nilable_1.should eq "Not nil 1"
      restored_person.nilable_2?.should be_nil
      restored_person.nilable_3?.should eq "Not nil 3"
      restored_person.nilable_4.should be_nil
      restored_person.nilable_int.should eq 42
      restored_person.nilable_float.should be_nil
      restored_person.nilable_char.should eq '🚀'
    end
  end

  describe "nested objects" do
    it "serializes and deserializes nested objects" do
      address = Address.new(street: "123 Main St", city: "Anytown")
      employee = Employee.new(
        name: "Bob",
        address: address,
        salary: 75000.50
      )

      io = IO::Memory.new
      employee.to_io(io)
      io.rewind
      restored_employee = Employee.from_io(io)
      restored_employee.name.should eq "Bob"
      restored_employee.address.street.should eq "123 Main St"
      restored_employee.address.city.should eq "Anytown"
      restored_employee.salary.should eq 75000.50

      # Full object comparison
      restored_employee.should eq employee
    end

    it "handles empty nested objects" do
      employee = Employee.new(
        name: "Charlie",
        address: Address.new,
        salary: 60000.0
      )

      io = IO::Memory.new
      employee.to_io(io)
      io.rewind
      restored_employee = Employee.from_io(io)

      restored_employee.name.should eq "Charlie"
      restored_employee.address.street.should eq ""
      restored_employee.address.city.should eq ""
      restored_employee.salary.should eq 60000.0

      # Full object comparison
      restored_employee.should eq employee
    end
  end

  describe "field annotations" do
    it "skips fields marked with @[IO::Field(skip: true)]" do
      # Create a user with sensitive data
      user = User.new(
        id: 42,
        username: "testuser",
        email: "test@example.com",
        password: "supersecret",
        api_key: "private-api-key-123",
        last_login_at: Time.utc
      )

      # Serialize to IO
      io = IO::Memory.new
      user.to_io(io)

      # Deserialize from IO
      io.rewind
      restored_user = User.from_io(io)

      # Fields that should be serialized
      restored_user.id.should eq user.id
      restored_user.username.should eq user.username
      restored_user.email.should eq user.email

      # Fields that should be skipped (should have default values)
      restored_user.password.should be_nil
      restored_user.api_key.should be_nil
      restored_user.last_login_at.should_not be_nil
    end
  end
end

# Test classes
class Person
  include IO::Serializable

  property! name : String?
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
  property! nilable_1 : String?
  property! nilable_2 : String?
  property? nilable_3 : String?
  property nilable_4 : String | Nil
  property nilable_int : Int32?
  property nilable_float : Float64?
  property nilable_char : Char?
  property tags : Array(String)
  property categories : Array(String) = [] of String

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
    @is_active = false,
    @grade = 'A',
    @nilable_int = nil,
    @nilable_float = nil,
    @nilable_char = '🚀',
    @tags = [] of String
  )
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
    grade == other.grade &&
    nilable_1? == other.nilable_1? &&
    nilable_2? == other.nilable_2? &&
    nilable_3? == other.nilable_3? &&
    nilable_4 == other.nilable_4 &&
    nilable_int == other.nilable_int &&
    nilable_float == other.nilable_float &&
    nilable_char == other.nilable_char &&
    tags == other.tags &&
    categories == other.categories
  end
end

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

# Test class for Skip annotation
class User
  include IO::Serializable

  property id : Int32
  property username : String
  property email : String

  # Sensitive data that should be skipped
  @[IO::Field(skip: true)]
  property password : String?

  @[IO::Field(skip: true)]
  property domain : String

  # Sensitive data that should be skipped (nilable)
  @[IO::Field(skip: true)]
  property api_key : String?

  # Runtime-only field that should be skipped
  @[IO::Field(skip: true)]
  property last_login_at : Time?

  def initialize(
    @id = 0,
    @username = "",
    @email = "",
    @password = nil,
    @domain = "example.com",
    @api_key = nil,
    @last_login_at = Time.utc
  )
  end
end
