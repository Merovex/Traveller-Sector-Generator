class WorldGenerator
  @@config = YAML::load(IO.read('_config.yml'))
  @@dice = YAML::load(IO.read('pregen_rolls.yml'))
  @@names = YAML::load_file('./worldgen/lib/names.yml')
  def toss(a=2,b=2)
    (@@dice.roll(a) - b).whole
  end
  def d3
    (@@dice.roll() / 2).ceil
  end
  def d66
    2.times.map { @@dice.roll.to_s }.inject{ |s,x| s + x}
  end
end
class Integer
  def dn(n)
       (1..self).inject(0) { |a, e| a + rand(n) + 1 }
  end
  def d6
    dn(6)
  end
  def hexd
    return 'F' if self > 15
    self.whole.to_s(16).upcase
  end
  def whole
    return 0 if self < 0
    return self
  end
  def natural
    return 1 if self < 1
    return self
  end
  def roman
    return 'D' if self ==500
    return %w{Ia Ib II III IV V VI VII VIII IX X}[self]
  end
  def max(n)
    return n if self > n
    return self
  end
  def min(n)
    return n if self < n
    return self
  end
end
class Array
  def roll(n=1)
    n.times.map{ self.shift }.inject{|s,x| s + x}
  end
end

require './worldgen/lib/sector'
require './worldgen/lib/volume'
require './worldgen/lib/svg'
    