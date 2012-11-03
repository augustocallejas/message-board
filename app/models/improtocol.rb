
##
# Major IM protocols.
#
##

class Improtocol
  private_class_method :new
  attr_reader :key, :name

  def initialize(key, name)
    @key = key
    @name = name
  end

  @@protos = {
    1 => new(1, "aim"),
    2 => new(2, "yahoo"),
    3 => new(3, "msn"),
    4 => new(4, "skype")
  }

  def self.aim
    return @@protos[:aim]
  end

  def self.yahoo
    return @@protos[:yahoo]
  end

  def self.msn
    return @@protos[:msn]
  end

  def self.skype
    return @@protos[:skype]
  end

  def self.find_all
    return @@protos.values()
  end

  def self.lookup(key)
    return @@protos.key?(key) ? @@protos[key] : None
  end

end
