class Volume<WorldGenerator
  def initialize(c,r)
    @name   = @@names.sample
    @column = c
    @row    = r
    @gas_giant = (@@config['giant_on'].include?(@@dice.roll(2)))
  end
  def location
    "%02d%02d" % [@column,@row]
  end
end