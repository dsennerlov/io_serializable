require "../src/io_serializable"

# Define a class to demonstrate file IO serialization
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

  def ==(other : Product)
    id == other.id &&
    name == other.name &&
    price == other.price &&
    is_available == other.is_available &&
    category == other.category
  end
end

# Create a sample product
product = Product.new(
  id: 123,
  name: "Crystal Programming Guide",
  price: 29.99,
  is_available: true,
  category: "Programming"
)

puts "Original product:"
puts "ID: #{product.id}"
puts "Name: #{product.name}"
puts "Price: $#{product.price}"
puts "Available: #{product.is_available}"
puts "Category: #{product.category}"

# Write to file
File.open("product.bin", "wb") do |file|
  product.to_io(file)
end

puts "\nProduct written to file: product.bin"

# Read from file
restored_product = File.open("product.bin", "rb") do |file|
  Product.from_io(file)
end

puts "\nRestored product:"
puts "ID: #{restored_product.id}"
puts "Name: #{restored_product.name}"
puts "Price: $#{restored_product.price}"
puts "Available: #{restored_product.is_available}"
puts "Category: #{restored_product.category}"

puts "\nProducts match: #{product == restored_product}"

# Clean up the file
File.delete("product.bin")
puts "\nTemporary file deleted"
