require "../src/io_serializable"

# Define an enum
enum Status
  Active = 1
  Inactive = 2
  Pending = 3
  Deleted = 4
end

# Define a class that uses the enum
class Task
  include IO::Serializable

  property id : Int32
  property title : String
  property status : Status
  property optional_status : Status?

  def initialize(@id = 0, @title = "", @status = Status::Pending, @optional_status = nil)
  end
end

# Create a task with an enum value
task = Task.new(
  id: 42,
  title: "Implement enum serialization",
  status: Status::Active,
  optional_status: Status::Inactive
)

puts "Original task:"
puts "ID: #{task.id}"
puts "Title: #{task.title}"
puts "Status: #{task.status} (#{task.status.value})"
puts "Optional Status: #{task.optional_status} (#{task.optional_status.try &.value})"

# Serialize to binary
io = IO::Memory.new
task.to_io(io)
puts "\nSerialized to #{io.size} bytes"

# Deserialize from binary
io.rewind
restored_task = Task.from_io(io)

puts "\nDeserialized task:"
puts "ID: #{restored_task.id}"
puts "Title: #{restored_task.title}"
puts "Status: #{restored_task.status} (#{restored_task.status.value})"
puts "Optional Status: #{restored_task.optional_status} (#{restored_task.optional_status.try &.value})"

# Create a task with a nil optional status
task2 = Task.new(
  id: 43,
  title: "Test nilable enum",
  status: Status::Pending,
  optional_status: nil
)

puts "\nOriginal task 2:"
puts "ID: #{task2.id}"
puts "Title: #{task2.title}"
puts "Status: #{task2.status} (#{task2.status.value})"
puts "Optional Status: #{task2.optional_status.inspect}"

# Serialize to binary
io2 = IO::Memory.new
task2.to_io(io2)
puts "\nSerialized to #{io2.size} bytes"

# Deserialize from binary
io2.rewind
restored_task2 = Task.from_io(io2)

puts "\nDeserialized task 2:"
puts "ID: #{restored_task2.id}"
puts "Title: #{restored_task2.title}"
puts "Status: #{restored_task2.status} (#{restored_task2.status.value})"
puts "Optional Status: #{restored_task2.optional_status.inspect}"
