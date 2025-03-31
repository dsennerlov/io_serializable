require "../src/io_serializable"

class NamedTupleExample
  include IO::Serializable

  property initialized : Bool = false
  property named_tuple : NamedTuple(id: Int32?, name: String, value: Float64?, active: Bool)

  def initialize(@initialized = false, @named_tuple = {id: nil, name: "", value: nil, active: false})
  end
end

# Create a new NamedTupleExample instance
example = NamedTupleExample.new(true)
puts example.inspect
example.named_tuple = {id: 42, name: "hello", value: 3.14, active: true}

# Create an in-memory buffer
io = IO::Memory.new

# Serialize the object to IO
example.to_io(io)

# Reset the buffer position to start
io.rewind
puts "IO: #{io.to_slice}"
# Deserialize the object from IO
read_example = NamedTupleExample.from_io(io)

puts "Original initialized: #{example.initialized}"
puts "Read initialized: #{read_example.initialized}"
puts "Original named tuple: #{example.named_tuple}"
puts "Read named tuple: #{read_example.named_tuple}"
puts "Named tuples match: #{example.named_tuple == read_example.named_tuple}"
puts "Read ID: #{read_example.named_tuple[:id]}"
puts "Read Name: #{read_example.named_tuple[:name]}"
puts "Read Value: #{read_example.named_tuple[:value]}"
puts "Read Active: #{read_example.named_tuple[:active]}"

# Direct named tuple serialization example
puts "\nDirect named tuple serialization example:"
named_tuple = {id: 99, name: "direct named tuple", value: 2.71828, active: false}

# Create a new buffer
direct_io = IO::Memory.new

# Write the named tuple directly
named_tuple.to_io(direct_io)

# Reset buffer position
direct_io.rewind
puts "Direct IO: #{direct_io.to_slice}"
# Read the named tuple directly
read_named_tuple = NamedTuple(id: Int32, name: String, value: Float64, active: Bool).from_io(direct_io)

puts "Original named tuple: #{named_tuple}"
puts "Read named tuple: #{read_named_tuple}"
puts "Named tuples match: #{named_tuple == read_named_tuple}"
puts "Read ID: #{read_named_tuple[:id]}"
puts "Read Name: #{read_named_tuple[:name]}"
puts "Read Value: #{read_named_tuple[:value]}"
puts "Read Active: #{read_named_tuple[:active]}"

# Nested named tuple example
puts "\nNested named tuple example:"
nested_named_tuple = {user: {id: 123, name: "John"}, scores: {math: 95.5, science: 87.0}}

# Create a new buffer
nested_io = IO::Memory.new

# Write the nested named tuple directly
nested_named_tuple.to_io(nested_io)

# Reset buffer position
nested_io.rewind
# Read the nested named tuple directly
read_nested = NamedTuple(
  user: NamedTuple(id: Int32, name: String),
  scores: NamedTuple(math: Float64, science: Float64)
).from_io(nested_io)

puts "Original nested named tuple: #{nested_named_tuple}"
puts "Read nested named tuple: #{read_nested}"
puts "Nested named tuples match: #{nested_named_tuple == read_nested}"
puts "Read User ID: #{read_nested[:user][:id]}"
puts "Read User Name: #{read_nested[:user][:name]}"
puts "Read Math Score: #{read_nested[:scores][:math]}"
puts "Read Science Score: #{read_nested[:scores][:science]}"
