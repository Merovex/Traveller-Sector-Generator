class Volume<WorldGenerator
  def initialize(c,r)
    @name      = @@names.sample
    @column    = c
    @row       = r
    @gas_giant = (@@config['giant_on'].include?(toss(2,2)))
    @station   = %w{X X X E E D D C C B B A A A A}[toss(2,0)]
    @size      = toss()
    @atmo      = toss()
    @temp      = %w{F F F C C T T T T T H H R R R R R }[toss(2,0)]
    
    @h20 = case 
      when (@size < 2) then 0
      when ([0,1,10,11,12].include?(@atmo)) then (toss(2,11) + @size).max(10)
      else @h20  = (toss(2,7) + @size).max(10)
    end
    @h20 -= 2 if @temp == 'H'
    @h20 -= 6 if @temp == 'R'
    @h20 = @h20.whole
    
    @popx = toss()
    @govm = (toss(2,7) + @popx).whole
    @law  = (toss(2,7) + @govm).whole
    
    @law = @govm = 0 if @popx == 0

    fax_r = d3
    fax_r += 1 if [0,7].include?(@law)
    fax_r -= 1 if @law > 9
    @factions = (@popx == 0) ? [] : fax_r.times.map do
      %w{O O O O F F M M N N S S P}[toss(2,0)]
    end 
    
  end
  def uwp
    "%s%s%s%s%s%s%s" % [ @station, @size.hexd, @atmo.hexd, @h20.hexd, @popx.hexd, @govm.hexd, @law.hexd]
  end
  def location
    "%02d%02d" % [@column,@row]
  end
end