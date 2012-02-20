class Sector<WorldGenerator
  attr_accessor :volumes
  def initialize
    @volumes = []
  end
  def generate
    40.times do |c|
      32.times do |r|
        if (@@config['world_on'].include?(@@dice.roll))
          v = Volume.new(c,r) 
          @volumes << v unless v.empty?
        end
      end
    end
  end
end