class Sector<WorldGenerator
  def initialize
    puts @@dice.roll(2)
    puts @@config.inspect
  end
  def generate
    40.times do |c|
      32.times do |r|
        if (@@config['world_on'].include?(@@dice.roll))
          v = Volume.new(c,r) 
          puts [v.uwp, v].inspect
        end
      end
    end
  end
end