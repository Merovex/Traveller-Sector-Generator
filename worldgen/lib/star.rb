class Star<WorldGenerator
  attr_accessor :star_size, :mass, :bode_constant, :biozone, :type_dm, :size_dm, :orbits, :primary, :orbit, :id, :volume, :world, :companions
  # @@stars   = {}
  STAR_CHART = {
    #type => 0)example,        1)temp, 2)lux,    3)mass, 4)radius
    'B0' => ['Becrux',           30000, 16000,     16.0,  5.70],
    'B2' => ['Spica',            22000,  8300,     10.5,  5.10],
    'B5' => ['Achernar',         15000,   750,      5.40, 3.70],
    'B8' => ['Rigel',            12500,   130,      3.50, 2.70],
    'A0' => ['Sirius A',          9500,    63,      2.60, 2.30],
    'A2' => ['Fomalhaut',         9000,    40,      2.20, 2.00],
    'A5' => ['Altair',            8700,    24,      1.90, 1.80],
    'F0' => ['Gamma Virginis',    7400,     9.0,    1.60, 1.50],
    'F2' => ['.',                 7100,     6.3,    1.50, 1.30],
    'F5' => ['Procyon A',         6400,     4.0,    1.35, 1.20],
    'G0' => ['Alpha Centauri A',  5900,     1.45,   1.08, 1.05],
    'G2' => ['The Sun',           5800,     1.00,   1.00, 1.00],
    'G5' => ['Mu Cassiopeiae',    5600,     0.70,   0.95, 0.91],
    'G8' => ['Tau Ceti',          5300,     0.44,   0.85, 0.87],
    'K0' => ['Pollux',            5100,     0.36,   0.83, 0.83],
    'K2' => ['Epsilon Eridani',   4830,     0.28,   0.78, 0.79],
    'K5' => ['Alpha Centauri B',  4370,     0.18,   0.68, 0.74],
    'M0' => ['Gliese 185',        3670,     0.075,  0.47, 0.63],
    'M2' => ['Lalande 21185',     3400,     0.03,   0.33, 0.36],
    'M4' => ['Ross 128',          3200,     0.0005, 0.20, 0.21],
    'M6' => ['Wolf 359',          3000,     0.0002, 0.10, 0.12]
  }
  INNER_LIMIT = {
    'O' => [  16, 13, 10 ],
    'B' => [   10, 6.3, 5.0, 4.0, 3.8, 0.6, 0],
    'A' => [    4,   1, 0.4,   0,   0,   0, 0],
    'F' => [    4,   1, 0.3, 0.1,   0,   0, 0],
    'G' => [  3.1,   1, 0.3, 0.1,   0,   0, 0],
    'K' => [  2.5,   1, 0.3, 0.1,   0,   0, 0],
    'M' => [    2,   1, 0.3, 0.1,   0,   0, 0],
    'D' => [  0 ],
  }
  BIOZONE = {
    'O' => [  [790,1190], [630,950], [500,750] ],
    'B' => [  [500,700], [320,480], [250,375], [200,300], [180,270], [30,45]   ],
    'A' => [  [200,300],   [50,75],   [20,30], [5.0,7.5], [4.0,6.0], [3.1,4.7] ],
    'F' => [  [200,300],   [50,75],   [13,19], [2.5,3.7], [2.0,3.0], [1.6,2.4], [0.5,0.8] ],
    'G' => [  [200,300],   [50,75],   [13,19], [2.5,3.7], [2.0,3.0], [1.6,2.4], [0.5,0.8] ],
    'K' => [  [125,190],   [50,75],   [13,19], [4.0,5.9], [1.0,1.5], [0.5,0.6], [0.2,0.3] ],
    'M' => [  [100,150],   [50,76],   [16,24], [5.0,7.5], [0,0], [0.1,0.2], [0.1,0.1] ],
    'D' => [  [0.03, 0.03] ],
  }
  SPECTRAL = {
    'O' => [9],
    'B' => [0,2,5,8],
    'A' => [0,2,5],
    'F' => [0,2,5],
    'G' => [0,2,5,8],
    'K' => [0,2,5],
    'M' => [0,2,4,6]
  }
  MASS = {
    'O' => [70, 60, 0, 0, 50, 0 ],
    'B' => [50, 40, 35, 30, 20, 10],
    'A' => [30, 16, 10, 6, 4, 3],
    'F' => [15, 13, 8, 2.5, 2.2, 1.9],
    'G' => [12, 10, 6, 2.7, 1.8, 1.1, 0.8],
    'K' => [15, 12, 6, 3, 2.3, 0.9, 0.5],
    'M' => [20, 16, 8, 4, 0.3, 0.2],
    'D' => [0.8,0.8,0.8,0.8,0.8,0.8,]
  }
  COMPANION_SEPARATION = [[0.05]*2, [0.5]*3, [2.0]*2, [10.0]*3, [50.0] * 10].flatten
  BODE_RATIO           = [[0.3] * 4, [0.35] * 3, [0.4] * 4].flatten
  def initialize(volume, primary=nil,ternary=0)
    @volume     = volume
    @primary    = primary
    @orbits     = []
    @companions = []
    @world      = nil
        
    @type_dm = 0
    @size_dm = 0
    @has_gg  = false
    
    if primary.nil?
      @orbit   = 0
      @type_dm = (toss(2,0) + @volume.star_dm ).max(12)
      @size_dm = (toss(2,0) + 0 ).max(12)
      @star_type = %w{B B A M M M M M K G F F F}[@type_dm] 
      @star_size = %w{0 1 2 3 4 5 5 5 5 5 5 6 500}[@size_dm].to_i
    else
      separation = (toss(2,0) * COMPANION_SEPARATION[toss(3) + (4 * ternary) - 2]).round(2) # Gurps Space 4e p.105

      @orbit = au_to_orbit(separation) - 1
      @star_type = %w{X B A F F G G K K M M M M}[(toss(2,0) + primary.type_dm).max(12)]
      @star_size = %w{0 1 2 3 4 500 500 5 5 6 500 500 500 500}[(toss(2,0) + primary.size_dm).max(12)].to_i
    end
    @spectral = @star_type + SPECTRAL[@star_type].sample.to_s
    @star_size ||= 500

    @bode_constant = (@star_type=='M' and @star_size==5) ? 0.2 : BODE_RATIO[toss]
      
    if @star_size == 500
      @star_subtype = (true) ? 'B' : @star_type
      @star_type = 'D'
    end

    dm = 0
    dm += 4 if @star_size == 3
    dm += 8 if @star_size < 3
    dm -= 4 if @star_type == 'M'
    dm -= 2 if @star_type == 'K'
    
    # Populate Orbits
    (toss(2,0) + dm).whole.times do |i|
      @orbits << Orbit.new(self,i).populate unless orbit_to_au(i) > outer_limit
      @world = @orbits.last if @orbits.last.is_a?(World)
    end
    @world.gas_giant = (@orbits.map{|o| o.kid}.include?('G')) ? 'G' : '.' unless @world.nil?
    prune!
  end
  def prune! # Ensure last orbits are not empty.
    @orbits.each_index { |x| @orbits[x] = Orbit.new(self,x) if @orbits[x].nil?}
    c = @orbits
    # exit
    tk = false
    @orbits = @orbits.sort{|b,a| a.orbit_number <=> b.orbit_number}.map {|o| tk = true unless (o.kid == '.' or tk); o if tk }.reverse.compact
    # @orbits.each_index { |x| @orbits[x] = Orbit.new(self,x) if @orbits[x].nil?}

    return if @orbits.size < 2
    @orbits.length.times do |i|
      @orbits[i].orbit_number = i
      @orbits[i].au = self.orbit_to_au(i)
    end

  end
  def orbit_to_au(o)
    inner_limit + (self.bode_constant * (2 ** o)).round(1)
  end
  def au_to_orbit(au)
    constant = (@primary.nil?) ? @bode_constant : @primary.bode_constant
    (Math.log(au / constant) / Math.log(2) ).round(2).abs - inner_limit
  end
  def companions=(star)
    orbit = star.orbit.abs
    companion = Companion.new(self, orbit, star)

    # Gurps Space 4e p.107 - Clear Forbidden orbits
    inner = au_to_orbit(companion.au * 0.67).floor
    outer = au_to_orbit(companion.au * 3).ceil
    @forbidden = (inner .. outer)
    @forbidden.each  { |x| @orbits[x] = nil }
    @orbits[orbit - 1] = companion
    @companions << star
    prune!
  end
  def to_s; kid; end
  def kid; 'C'; end
  def radius; (155000 * Math.sqrt(luminosity)) ** 2; end # Gurps Space 4e p. 104
  def snow_line; 4.85 * Math.sqrt(luminosity);       end # Gurps Space 4e p. 106
  def outer_limit; 40 * mass; end # Gurps Space 4e p. 107
  def orbits_to_ascii
    return '' if @orbits.empty?
    "\n" + @orbits.map{|o| o.to_ascii}.join("\n") + "\n"
  end
  def crib
    stars = [classification]
    @companions.each { |s| stars << s.classification }
    "%-17s %-16s" % [stars.join('/'), @orbits.map{|o| o.kid}.join('')]
  end
  def to_ascii
    classification
  end
  def classification
    return @star_type + @star_subtype if (@star_type == 'D')
    "#{@spectral}#{@star_size.roman}"
  end
  def world?
    return @orbits.join('').include?('W')
    return false
  end
  def column; @volume.column; end
  def row; @volume.row; end
  def sector; @volume.sector; end
  def location; @volume.location; end
  def type; @star_type; end
  def type=(s); @star_type = s; end
  def size; @star_size; end
  def size=(s); @star_size = s; end 
  def inner_limit; limit; end
  def limit
    return 0 if @star_size.nil?
    INNER_LIMIT[@star_type][@star_size % 10]
  end
  def biozone; BIOZONE[@star_type][@star_size % 10] or []; end
  def luminosity; STAR_CHART[@spectral][2]; end
  def temperature; @temperature = STAR_CHART[@spectral][1].around(20) if @temperature.nil?; end
  def mass; MASS[@star_type][@star_size] || 0.3; end
end
