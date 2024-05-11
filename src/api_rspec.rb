require 'rspec'
require_relative 'api'
require_relative 'product'

describe ProductAPI do
  let(:api) { ProductAPI.new }

  describe '#add_product' do
    it 'adds a new product' do
      id = 100
      name = 'Potato'
      username = 'admin'
      password = 'password'
      token = api.authenticate(username, password)

      response = api.add_product(id, name, token)

      expect(response).to eq("Product ##{id}: #{name} created successfully.").or(eq("Product with ID ##{id} already exists. ID must be unique!"))
      expect(api.get_products(token)).to include(Product.new(id, name))
    end
  end

  describe '#get_product' do
    it 'returns product with given id' do
      id = 2
      expected_product = Product.new(id, 'Banana')

      username = 'admin'
      password = 'password'
      token = api.authenticate(username, password)

      product = api.get_product(id, token)

      expect(product).to eq(expected_product)
    end

    it 'fails when not authenticated' do
      id = 2
      token = nil
      response = api.get_product(id, token)
      expect(response).to eq("Authentication failed. Invalid token.")
    end
  end

  describe '#authenticate' do
    it 'returns a valid token when using default credentials' do
      username = 'admin'
      password = 'password'
      token = api.authenticate(username, password)
      expect(token).not_to be_nil
    end

    it 'retruns nil when invalid credentials' do
      username = 'wrong'
      password = 'user'
      token = api.authenticate(username, password)
      expect(token).to be_nil
    end
  end


end
