require 'contracts'

require_relative 'page'
require_relative 'gws'

include Contracts

# Item
class Item
  # Contract XmlElement => Item
  def initialize(name, content)
    @klass = Object.const_get(name).new(content)
  end

  def method_missing(m, *args)
    @klass.send(m, *args)
  end
end
