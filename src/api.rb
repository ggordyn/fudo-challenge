require 'json'
require 'securerandom'


class ProductAPI
  PRODUCTS_JSON = "products.json"

  def initialize
    @products = load_products
    @auth_tokens = {}
  end

  def load_products
    File.exist?(PRODUCTS_JSON) ? JSON.parse(File.read(PRODUCTS_JSON)).map { |p| Product.from_json(p.to_json) } : []
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
      @products
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
    # TODO get user list from file
    username == "admin" && password == "password"
  end

  def generate_token
    SecureRandom.uuid
  end

  def authenticate_token(token)
    @auth_tokens.value?(token)
  end

end
