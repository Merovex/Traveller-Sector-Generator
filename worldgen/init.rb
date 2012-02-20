class WorldGenerator
  @@config = YAML::load(IO.read('_config.yml'))
  @@dice = YAML::load(IO.read('pregen_rolls.yml'))
end

require './worldgen/lib/sector'
require './worldgen/lib/svg'


class Integer
  def dn(n)
       (1..self).inject(0) { |a, e| a + rand(n) + 1 }
  end
  def d6
    dn(6)
  end
end
class Array
  def roll(n=1)
    n.times.map{ self.shift }.inject{|s,x| s + x}
  end
end
    