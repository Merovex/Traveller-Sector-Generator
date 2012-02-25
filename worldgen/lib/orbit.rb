class Orbit<WorldGenerator
  @@orbits
  attr_accessor :id, :uwp, :kid
  def initialize(star,orbit_number,companion=nil)
    @orbit_number = orbit_number
    @tc       = ''
    @au = (star.bode_constant * (2 ** orbit_number)).round(1)
    @kid = '.'
    @star = star
    begin
      @zone = case
        when @au < @star.biozone[0] then -1 # Inside
        when @au > @star.biozone[1] then 1  # Outside
        else 0
      end
      @distant = (@au > @star.biozone[1] * 10)
    rescue
      # There is no biozone, so all is "inside"
      @zone = -1
      @distant = 1000
    end
    
  end
  def populate
    case
      when @au > 2500 then return self
      when limit? then return self
      when inner? then populate_inner
      when outer? then populate_outer
      else populate_biozone
    end
  end
  def populate_biozone
    roll = toss(2,0)
    return case
      when roll < 4 then self
      when (4..10) === roll then World.new(@star, @orbit_number)
      when 11 == roll then Belt.new(@star, @orbit_number) 
      else GasGiant.new(@star, @orbit_number)
    end
  end
  def populate_inner
    roll = toss(2,0)
    return case
      when roll < 5 then self
      when (5..6) === roll then Hostile.new(@star, @orbit_number)
      when (7..9) === roll then Rockball.new(@star, @orbit_number)
      when (10..11) === roll then Belt.new(@star, @orbit_number)   
      else GasGiant.new(@star, @orbit_number)
    end
  end
  def populate_outer
    roll = 1.d6
    roll += 1 if distant?
    return case
      when roll == 1 then Terrestrial.new(@star, @orbit_number)
      when roll == 2 then Belt.new(@star, @orbit_number)
      when roll == 3 then self
      when (4..7) === roll then GasGiant.new(@star, @orbit_number)
      else Rockball.new(@star, @orbit_number)
    end
  end
  def to_ascii
    bio = (@zone == 0 ) ? '*' : ' '
    "  -- %2s. %s (%7.2f) %s" % [@orbit_number, bio, @au, @kid]
  end
  # def to_ascii
  #   details = (self.is_a?(World)) ? self.uwp : ''
  #   bio = (@zone == 0 ) ? '*' : ' '
  #   if (self.class.name == 'Orbit') 
  #     "      %2s. %s %-11s %-9s" % [@orbit_number + 1, bio, '...', '...']
  #   else
  #     "      %2s. (%7.2f) %s %-11s %-9s // %s >> %s" % [@orbit_number + 1, @au, bio, self.class.name, @uwp, @tc,  @moons]
  #   end
  #   # self.inspect
  # end
  def period; (@au * 365.25).round(2); end
  def km; return (150000000 * @au).to_i; end
  def radii; (@au * 200).to_i; end
  def limit?;   return @au < @star.limit ; end
  def inner?;   return @zone < 0; end
  def outer?;   return @zone > 0; end
  def biozone?; return @zone == 0; end
  def distant?; @distant; end
end

class Companion<Orbit
  def initialize(star,orbit_number,companion)
    
    @star = companion
    @au = 1.d6 * 1000 if @star.orbit > 15
    super
    @uwp = @star.classification
  end
end
class Belt<Orbit; end

class Planet<Orbit
  def initialize(star,orbit_number)
    @size = 2.dn(5) if @size.nil?
    @moons = (1.d6 - 3).whole
    super
  end
end

class Rockball<Planet; end
class World<Planet; end
class Terrestrial<Planet; end
class Hostile<Planet
  def initialize(star,orbit_number)
    
    @atmo = (10..15).to_a.sample
    @hydro = 2.dn(4) - 2
    @kid = 'H'
    while @atmo == 15
      @atmo = (10..15).to_a.sample
    end
    super
  end
end

class GasGiant<Planet
  def initialize(star,orbit_number)
    super
    size = (1.d6 < 4) ? 'L' : 'S'
    @uwp  = "XGG#{size}000-0"
    @moons = toss(2,0)
    @moons = (@moons - 4).whole if size == 'S'
    @kid = 'G'
  end
end
class Moon
  def initalize(planet)
    @size = (toss(2,0) - planet.size).whole
  end
end