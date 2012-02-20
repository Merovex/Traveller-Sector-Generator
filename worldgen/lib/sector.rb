class Sector<WorldGenerator
  def initialize
    puts @@dice.roll(2)
    puts @@config.inspect
  end
  def generate
    40.times do |c|
      32.times do |r|
        puts "%02d%02d" % [c,r, Volume.new] if (@@config['world_on'].include?(@@dice.roll))
      end
    end
  end
end