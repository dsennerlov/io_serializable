require "../src/io_serializable"

class TupleExample
  include IO::Serializable

  property initialized : Bool = false
  property tuple : Tuple(Int32, String, Float64, Bool)

  def initialize(@initialized = false, @tuple = {0, "", 0.0, false})
  end
end

# Create a new TupleExample instance
example = TupleExample.new(true)
puts example.inspect
example.tuple = {42, "hello", 3.14, true}

# Create an in-memory buffer
io = IO::Memory.new

# Serialize the object to IO
example.to_io(io)

# Reset the buffer position to start
io.rewind
puts "IO: #{io.to_slice}"
# Deserialize the object from IO
read_example = TupleExample.from_io(io)

puts "Original initialized: #{example.initialized}"
puts "Read initialized: #{read_example.initialized}"
puts "Original tuple: #{example.tuple}"
puts "Read tuple: #{read_example.tuple}"
puts "Tuples match: #{example.tuple == read_example.tuple}"

# Direct tuple serialization example
puts "\nDirect tuple serialization example:"
tuple = {99, "direct tuple", 2.71828, false}

# Create a new buffer
direct_io = IO::Memory.new

# Write the tuple directly
tuple.to_io(direct_io)

# Reset buffer position
direct_io.rewind
puts "Direct IO: #{direct_io.to_slice}"
# Read the tuple directly
read_tuple = Tuple(Int32, String, Float64, Bool).from_io(direct_io)

puts "Original tuple: #{tuple}"
puts "Read tuple: #{read_tuple}"
puts "Tuples match: #{tuple == read_tuple}"


