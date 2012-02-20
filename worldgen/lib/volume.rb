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
    
    @trades = get_trade_codes
    
    @code   = (@atmo > 9 or [0,7,10].include?(@law) or [0,9,10,11,12,13,14,15,16].include?(@law)) ? 'AZ' : '..'
  end
  def get_trade_codes
    code = []
    code << 'Ag' if ((4..9) === @atmo and (4..8) === @h20 and  (5..7) === @popx)
    code << 'As' if (@size == 0 and @atmo == 0 and @h20 ==0)
    code << 'Ba' if (@popx == 0 and @govm == 0 and @law == 0)
    code << 'De' if (@atmo > 1 and @h20 == 0)
    code << 'Fl' if (@atmo > 9 and @h20 > 0)
    code << 'Ga' if (@size > 4 and (4..9) === @atmo and (4..8) === @hydro)
    code << 'Hi' if (@popx > 8)
    code << 'Ht' if (@tek > 12)
    code << 'IC' if (@atmo < 2 and @h20 > 0)
    code << 'In' if ([0,1,2,4,7,9].include?(@atmo) and @popx > 8)
    code << 'Lo' if ((1..3) === @popx)
    code << 'Lt' if (@tek < 6)
    code << 'Na' if ((0..3) === @atmo and (0..3) === @h20 and @popx > 5)
    code << 'NI' if ((4..6) === @popx)
    code << 'Po' if ((2..5) === @atmo and (0..3) === @h20)
    code << 'Ri' if ([6,8].include?(@atmo) and (6..8) === @popx)
    code << 'Va' if (@atmo == 0)
    code << 'Wa' if (@hydro == 10)
    code
  end
  def to_s
    "%s %s %s %s %s %s\t%-15s\t%s\t%s" % [location, uwp, @temp, @gas_giant, @bases, @code, @trades.join(','), @factions.join(','), @name]
  end
  def uwp
    "%s%s%s%s%s%s%s-%s" % [ @port, @size.hexd, @atmo.hexd, @h20.hexd, @popx.hexd, @govm.hexd, @law.hexd, @tek.hexd]
  end
  def location
    "%02d%02d" % [@column,@row]
  end
end
