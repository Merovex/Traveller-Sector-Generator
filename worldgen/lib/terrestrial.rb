class Terrestrial<Planet  
  def initialize(star,orbit_number)
    super
    @kid       = 'R'
    
    # Size, Climate & Biosphere. MgT 170--71.
    @size      = toss(2,1)
    @atmo      = toss()
                            # 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, F 
    temp_dice  = toss(2,0) + [0, 0,-2,-2,-1,-1, 0, 0, 1, 1, 2, 6, 6, 2,-1, 2][@atmo]
    
    @temp      = %w{F F F C C T T T T T H H R R R R R }[temp_dice]
    
    # Hydrographics. MgT p. 172
    @h20 = case 
      when (@size < 2 or !biozone?) then 0
      when ([0,1,10,11,12].include?(@atmo)) then (toss(2,11) + @size).max(10)
      else @h20  = (toss(2,7) + @size).max(10)
    end
    @h20 -= 2 if @temp == 'H'
    @h20 -= 6 if @temp == 'R'
    @h20 = @h20.whole
    
    # Adjust Atmosphere and Hydrographics when not Normal. MgT p. 180.
    if (%{opera firm}.include?(@@config['genre'].downcase))
      @atmo = case
        when (@size < 3 or (@size < 4 and @atmo < 3)) then 0
        when ([3,4].include?(@size) and (3..5).include?(@atmo)) then 1
        when ([3,4].include?(@size) and @atmo > 5) then 10
        else @atmo
      end
      @h20 -= 6 if (((3..4).include?(@size) and @atmo == 'A' ) or @atmo < 2)
      @h20 -= 4 if ([2,3,11,12].include?(@atmo))
    end
  end
end
class World<Terrestrial
  attr_accessor :factions, :temp, :gas_giant
  def initialize(star,orbit_number)
    super
    
    @port_roll = toss(2,0)
    
    @kid = 'W'
    @popx = toss()
    if ('firm' == @@config['genre'].downcase)
      @popx -= 1 if (@size < 3 or @size > 9)
      @popx += [-1, -1, -1, -1, -1, 1, 1, -1, 1, -1, -1, -1, -1, -1, -1, -1][@atmo]
      @port_roll = (@port_roll - 7 + @popx.whole).whole
    end
    @popx = @popx.whole
    
    # Government & Law. MgT p. 173
    @govm = (toss(2,7) + @popx).whole
    @law  = (toss(2,7) + @govm).whole

    # Identify Factions. MgT p. 173
    fax_r = d3.max(3)
    fax_r += 1 if [0,7].include?(@law)
    fax_r -= 1 if @law > 9
    rolls = [toss(2,0),toss(2,0),toss(2,0),toss(2,0),toss(2,0)]
    @factions = (@popx == 0) ? [] : fax_r.times.map { |r| %w{O O O O F F M M N N S S P}[rolls.shift] }
    
    # Set Technology die modifier based on World attributes. MgT p. 170
    tek_dm = { 'A' => 6, 'B' => 4, 'C' => 2, 'D' => 0, 'E' => 0, 'X' => -4}[port]
    tek_dm += [2,2,1,1,1,0,0,0,0,0,0,0,0,0,0,0][@size]
    tek_dm += [1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1][@atmo]
    tek_dm += [1,0,0,0,0,0,0,0,0,1,2][@h20]
    tek_dm += [0,1,1,1,1,1,0,0,0,1,2,3,4][@popx]
    tek_dm += [1,0,0,0,0,1,0,2,0,0,0,0,0,-2,-2,0][@govm]
    tek_limit = environmental_tek_limits[@atmo]
    @tek = (toss(1,0) + tek_dm).min( tek_limit ) # MgT p. 179 Environmental Limits
    
    # For those who want to limit technology
    @tek  = @tek.max(@@config['tech_cap']) unless @@config['tech_cap'].nil?
    @tek  = @tek.min(tek_limit)
    @tek  = @tek.min(@popx)
    @law  = @govm = @tek = 0 if @popx == 0
    
    # Fix temperature (Me)
    @temp = 'F' if (trade_codes.include?('IC') or trade_codes.include?('Va'))
    @temp = 'T' if ((trade_codes.include?('Ag') or trade_codes.include?('Ga') or trade_codes.include?('Ri') or trade_codes.include?('Wa')) and @temp != 'T')

    base = {      
      "Navy"      => { 'A' => 8,  'B' => 8,  'C' => 20, 'D' => 20, 'E' => 20, 'X' => 20 }[port],
      "Scout"     => { 'A' => 10, 'B' => 8,  'C' =>  8, 'D' =>  7, 'E' => 20, 'X' => 20 }[port],
      "Consolate" => { 'A' => 6,  'B' => 8,  'C' => 10, 'D' => 20, 'E' => 20, 'X' => 20 }[port],
      "Pirate"    => { 'A' => 20, 'B' => 12, 'C' => 10, 'D' => 12, 'E' => 20, 'X' => 20 }[port]
    }

    @base = {}
    base.keys.each  {|key| @base[key] = (2.d6 > base[key] - 1) ? key[0] : '.'}
  end
  def travel_code
    @code = (@atmo > 9 or [0,7,10].include?(@govm) or [0,9,10,11,12,13].include?(@law)) ? 'AZ' : '..'
  end
  def gravity
    @gravity = [0,0.05,0.15,0.25,0.35,0.45,0.7,0.9,1.0,1.25,1.4][@size] if @gravity.nil?
    @gravity
  end
  def bases
    return [@base['Navy'],@base['Scout'],@gas_giant,@base['Consolate'],@base['Pirate']].join('')
  end
  def port
    %w{X X X E E D D C C B B A A A A A A A A A}[@port_roll.whole]
  end
  def environmental_tek_limits
    [8,8,5,5,3,0,0,3,0,8,9,10,5,8]
  end
  def empty?
    (uwp.include?('X000000'))
  end
  def trade_codes
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
end