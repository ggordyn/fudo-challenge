class Product

  attr_accessor :id, :name

  def initialize(id, name)
    @id = id
    @name = name
  end

  def ==(other)
    return false unless other.is_a?(Product)

    id == other.id && name == other.name
  end

  def to_s
    "#{@id}: #{@name}"
  end

  def to_json(*args)
    {id: @id, name: @name}.to_json(*args)
  end

  def self.from_json(json)
    data = JSON.parse(json)
    new(data['id'], data['name'])
  end


end
