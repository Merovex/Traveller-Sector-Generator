class Orbit<WorldGenerator
  attr_accessor :id, :kid, :au, :port, :orbit_number, :xsize
  def initialize(star,orbit_number,companion=nil)
    @orbit_number = orbit_number.round
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
    @xsize = '.'
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
    '.......-.' # "%s%s%s%s%s%s%s-%s" % [port, @size.hexd, @atmo.hexd, @h20.hexd, @popx.hexd, @govm.hexd, @law.hexd, @tek.hexd]
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
    roll = toss(1,0)
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
    output = "  -- %2s. %s  %s // %s // (%7.2f)" % [@orbit_number + 1, bio, @kid, self.uwp, @au]
    @moons.each {|m| output += m.to_ascii} unless @moons.nil? or @moons == 0
    output
    
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
    super
    @moons = make_moons(toss(1,3))
    @size = toss if @size.nil? or @size == 0
  end
  def make_moons(c)
    moons = {}
    c.times { |i|
      m = Moon.new(self,i)
      moons["#{m.orbit}"] = m
    }
    moons.values.sort{ |a,b| a.orbit <=> b.orbit } unless @moons.size < 2
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
    @xsize = (toss(1,0) < 4) ? 'L' : 'S'
    moons = toss(2,0)
    moons = (moons - 4).whole if @xsize == 'S'
    @moons = make_moons(moons)
    @kid = 'G'
  end
  def uwp
    (@xsize == 'S') ? 'SmallGG' : 'LargeGG'
  end
end
class Moon<WorldGenerator
  attr_accessor :orbit, :size, :h20
  @@orbits = { 'C' => (1..14).to_a, 'R' => [1,1,1,2,2,3] }
  @@orbits['F'] = @@orbits['C'].map{|c| c * 5}
  @@orbits['E'] = @@orbits['C'].map{|c| c * 25}
  
  def initialize(planet,i=0)
    @planet = planet
    @popx = 0
    @law  = 0
    @tek  = 0
    @govm = 0
    @size = case
      when @planet.xsize = 'L' then toss(2,4)
      when @planet.xsize = 'S' then toss(2,6)
      else @planet.size - toss(1,0)
    end
    orbit = toss(2,i)
    @orbit = (case
      when (@size < 1) then @@orbits['R'][toss(1,1)]
      when (orbit == 12 and @planet.xsize == 'L') then @@orbits['E'][toss(2,0)]
      when (orbit < 8) then @@orbits['C'][toss(2,0)]
      when (orbit > 7) then @@orbits['C'][toss(2,0)]
      else 0
    end).whole
    @h20 = (case
      when (@planet.inner?) then 0
      when (@size == 0)    then 0
      when (@planet.outer?) then toss(2,4)
      when (@planet.biozone?) then toss(2,7)
      else 0
    end).whole
    @atmo = toss(2,7) + @size
    @atmo = (case
      when (@size == 0) then 0
      when (@planet.inner?) then @atmo - 4
      when (@planet.outer?) then @atmo - 4 
      else 0
    end).whole
  end
  def to_ascii
    "\n                %3d - %s" % [@orbit, uwp]
  end
  def uwp
    size = case
      when @size < 0 then 'S'
      when @size == 0 then 'R'
      else @size.hexd
    end
    # size = (@size == 0) ? 'R' : @size.hexd
    "%s%s%s%s%s%s%s" % ['x', size,@atmo.hexd,@h20.hexd,@popx.hexd,@govm.hexd,@law.hexd]
  end
end
