class Orbit<WorldGenerator
  attr_accessor :id, :kid, :au, :port, :orbit_number
  def initialize(star,orbit_number,companion=nil)
    @orbit_number = orbit_number.round
    @tc    = ''
    # @au    = (star.bode_constant * (2 ** orbit_number)).round(1)
    @au = star.orbit_to_au(orbit_number)
    @kid   = '.'
    @star  = star
    @size  = 0
    @atmo  = 0
    @moons = 0
    @h20   = 0
    @popx  = 0
    @tek   = 0
    @port  = 'X'
    @govm  = 0
    @law   = 0
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
  def uwp
    '...' # "%s%s%s%s%s%s%s-%s" % [port, @size.hexd, @atmo.hexd, @h20.hexd, @popx.hexd, @govm.hexd, @law.hexd, @tek.hexd]
  end
  def port
    @port || 'X'
  end
  def populate
    case
      when @au > @star.outer_limit then return self
      when limit? then return self
      when inner? then populate_inner
      when outer? then populate_outer
      else populate_biozone
    end
  end
  def populate_biozone
    return World.new(@star, @orbit_number)
    roll = toss(2,0)
    return (roll < 12) ? World.new(@star, @orbit_number) : GasGiant.new(@star, @orbit_number)
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
      when roll == 1 then Rockball.new(@star, @orbit_number)
      when roll == 2 then Belt.new(@star, @orbit_number)
      when roll == 3 then self
      when (4..7) === roll then GasGiant.new(@star, @orbit_number)
      else Rockball.new(@star, @orbit_number)
    end
  end
  def to_s
    @kid
  end
  def to_ascii
    bio = (@zone == 0 ) ? '*' : ' '
    bio = '-' if @au > @star.outer_limit
    "  -- %2s. %s (%7.2f) %s // %s" % [@orbit_number + 1, bio, @au, @kid, self.uwp]
  end
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
    @star = star
    @comp = companion
    super
    @kid = 'S'
  end
  def uwp
    @comp.classification
  end
end
class Belt<Orbit; end
class Planet<Orbit
  def initialize(star,orbit_number)
    @moons = toss(1,3)
    super
    @size = toss if @size.nil? or @size == 0
  end
  def uwp
    "%s%s%s%s%s%s%s-%s" % [port, @size.hexd, @atmo.hexd, @h20.hexd, @popx.hexd, @govm.hexd, @law.hexd, @tek.hexd]
  end
end
class Rockball<Planet
  def initialize(star,orbit_number)
    super
    @kid = 'R'
  end
end
class Hostile<Planet
  def initialize(star,orbit_number)
    super
    @atmo = [10,11,12,13,14].sample
    @hydro = toss(2,4)
    @kid = 'H'
  end
end
class GasGiant<Planet
  def initialize(star,orbit_number)
    super
    @xsize = (1.d6 < 4) ? 'L' : 'S'
    @moons = toss(2,0)
    @moons = (@moons - 4).whole if @xsize == 'S'
    @kid = 'G'
  end
  def uwp
    "XGG#{@xsize}000-0"
  end
end
class Moon
  def initalize(planet)
    @size = (toss(2,0) - planet.size).whole
  end
end