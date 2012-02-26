class Volume<WorldGenerator
  attr_accessor :gas_giant
  def initialize(c,r)
    @name   = @@names.sample
    @column = c
    @row    = r
    @star   = Star.new(self)
    [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2][toss(2,0)].times do |i|
      @star.companions = Star.new(self, @star,i)
    end
  end
  def star_dm
    return 0 if @atmo.nil? or @popx.nil?
    ((4..9).include?(@atmo) or @popx > 7) ? 4 : 0
  end
  def to_ascii
    w = @star.world
    sumy = "%s %s %s %s %s\t%-15s\t%-8s\t%s\t%s" % [location, w.uwp, w.temp, w.bases, w.travel_code, w.trade_codes.join(','), w.factions.join(','), @star.crib, @name]
    sumy += @star.orbits_to_ascii
    return sumy
  end
  def empty?
    return true if @star.world.nil? or @star.world.empty? or !@star.world?
  end
  def location
    "%02d%02d" % [@column,@row]
  end
end
