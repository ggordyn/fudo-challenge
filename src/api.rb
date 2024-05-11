require 'json'
require 'securerandom'
require 'net/http'


class ProductAPI
  PRODUCTS_JSON = "/app/src/products.json"

  def initialize
    @products = load_products
    sync_external_products
    @auth_tokens = {}
  end

  def load_products
    if File.exist?(PRODUCTS_JSON)
      JSON.parse(File.read(PRODUCTS_JSON)).map { |p| Product.from_json(p.to_json) }
    else
      puts "The products file #{PRODUCTS_JSON} does not exist."
      []
    end
  end

  def save_products
    File.write(PRODUCTS_JSON, @products.to_json)
  end

  def authenticate(username, password)
    if valid_credentials?(username, password)
      token = generate_token
      @auth_tokens[username] = token
      token
    else
      nil
    end
  end

  def add_product_async(id, name, token)
    Concurrent::Promise.execute do
      response = add_product(id, name, token)
      response
    end
  end

  def add_product(id, name, token)
    if authenticate_token(token)
      begin
        validate_unique(id)
        @products << Product.new(id, name)
        save_products
        "Product ##{id}: #{name} created successfully."
      rescue StandardError => e
        e.message
      end
    else
      "Authentication failed. Invalid token."
    end
  end


  def get_products(token)
    if authenticate_token(token)
      @products.sort_by(&:id)
    else
      "Authentication failed. Invalid token."
    end
  end

  def get_product(id, token)
    if authenticate_token(token)
      product = @products.find { |product| product.id == id }
      product.nil? ? "Product not found." : product
    else
      "Authentication failed. Invalid token."
    end
  end

  private

  def validate_unique(id)
    if @products.any? { |product| product.id == id }
      raise "Product with ID ##{id} already exists. ID must be unique!"
    end
  end

  def valid_credentials?(username, password)
    # Mock unsafe validation - would ideally use hashing operation and compare hash w/ database
    username == "admin" && password == "password"
  end

  def generate_token
    SecureRandom.uuid
  end

  def authenticate_token(token)
    @auth_tokens.value?(token)
  end

  def sync_external_products
    uri = URI('https://23f0013223494503b54c61e8bee1190c.api.mockbin.io/')
    res = Net::HTTP.post(uri, '{}', 'Content-Type' => 'application/json')
    data = JSON.parse(res.body)
    new_products = data['data'].map { |p| Product.new(p['id'], p['name']) }
    merge_products(new_products)
  end

  def merge_products(new_products)
    new_products.each do |new_p|
      # Skip if product already synced
      next if @products.any? { |p| p.id == new_p.id }
      @products << new_p
    end

    save_products
  end

end
