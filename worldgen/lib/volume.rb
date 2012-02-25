class Volume<WorldGenerator
  attr_accessor :gas_giant
  def initialize(c,r)
    @name      = @@names.sample
    @column    = c
    @row       = r
    @navy      = '.'
    @scout     = '.'
    # @gas_giant = (@@config['giant_on'].include?(toss(2,2))) ? 'G' : '.'
    @port_roll = toss(2,0)
    @star      = Star.new(self)
    @star.populate!
  end
  def star_dm
    return 0 if @atmo.nil? or @popx.nil?
    ((4..9).include?(@atmo) or @popx > 7) ? 4 : 0
  end
  def to_s
    w = @star.world
    "%s %s %s %s %s\t%-15s\t%-8s\t%-5s\t%s" % [location, w.uwp, @temp, w.bases, @code, w.trade_codes.join(','), w.factions.join(','), @star.classification, @name]
  end
  def empty?
    return true if @star.world.nil? or @star.world.empty?
  end
  def location
    "%02d%02d" % [@column,@row]
  end
end
