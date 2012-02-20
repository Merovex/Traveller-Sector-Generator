class Volume<WorldGenerator
  def initialize(c,r)
    @name      = @@names.sample
    @column    = c
    @row       = r
    @gas_giant = (@@config['giant_on'].include?(toss(2,2))) ? 'G' : '.'
    @port   = %w{X X X E E D D C C B B A A A A}[toss(2,0)]
    
    # Size, Climae & Biosphere. MgT 170--71.
    @size      = toss()
    @atmo      = toss()
                            # 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, F 
    temp_dice  = toss(2,0) + [0, 0,-2,-2,-1,-1, 0, 0, 1, 1, 2, 6, 6, 2,-1, 2][@atmo]
    
    @temp      = %w{F F F C C T T T T T H H R R R R R }[temp_dice]
    
    @trades = []
    @bases  = '.....'
    
    # Hydrographics. MgT p. 172
    @h20 = case 
      when (@size < 2) then 0
      when ([0,1,10,11,12].include?(@atmo)) then (toss(2,11) + @size).max(10)
      else @h20  = (toss(2,7) + @size).max(10)
    end
    @h20 -= 2 if @temp == 'H'
    @h20 -= 6 if @temp == 'R'
    @h20 = @h20.whole
    
    @popx = toss()
    
    # Government & Law. MgT p. 173
    @govm = (toss(2,7) + @popx).whole
    @law  = (toss(2,7) + @govm).whole
    @law = @govm = 0 if @popx == 0

    # Identify Factions. MgT p. 173
    fax_r = d3
    fax_r += 1 if [0,7].include?(@law)
    fax_r -= 1 if @law > 9
    @factions = (@popx == 0) ? [] : fax_r.times.map { %w{O O O O F F M M N N S S P}[toss(2,0)] }
    
    # Set Technology die modifier based on World attributes. MgT p. 170
    tek_dm = { 'A' => 6, 'B' => 4, 'C' => 2, 'D' => 0, 'E' => 0, 'X' => -4}[@port]
    tek_dm += [2,2,1,1,1,0,0,0,0,0,0,0,0,0,0,0][@size]
    tek_dm += [1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1][@atmo]
    tek_dm += [1,0,0,0,0,0,0,0,0,1,2][@h20]
    tek_dm += [0,1,1,1,1,1,0,0,0,1,2,3,4][@popx]
    tek_dm += [1,0,0,0,0,1,0,2,0,0,0,0,0,-2,-2,0][@govm]
    @tek = (toss(1,0) + tek_dm).min( [8,8,5,5,3,0,0,3,0,8,9,10,5,8][@atmo] ) # MgT p. 179 Environmental Limites
    
  end
  def to_s
    "%s %s %s %s %s %s\t%s" % [@location, uwp, @trades.join(','),@temp, @gas_giant, @bases, @name]
  end
  def uwp
    "%s%s%s%s%s%s%s-%s" % [ @port, @size.hexd, @atmo.hexd, @h20.hexd, @popx.hexd, @govm.hexd, @law.hexd, @tek.hexd]
  end
  def location
    "%02d%02d" % [@column,@row]
  end
end