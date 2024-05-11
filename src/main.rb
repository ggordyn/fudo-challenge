require_relative 'product'
require_relative 'api'
require 'concurrent'

api = ProductAPI.new

puts "Enter username:"
username = gets.chomp
puts "Enter password:"
password = gets.chomp

token = api.authenticate(username, password)

if token
  puts "------"
  puts "Authenticated with token #{token}"
  puts "------"


  # Get product list
  puts "Product list:"
  puts api.get_products(token)
  puts "------"


  # Add product
  add_product_promise = api.add_product_async(7, "Orange", token)
  if add_product_promise.wait
    puts add_product_promise.value
    puts "------"
    # Get product by ID
    puts "Product by ID: 7"
    puts api.get_product(7, token)
  else
    puts "Promise did not finish within the timeout"
  end

else
  puts "Authentication failed."
end
