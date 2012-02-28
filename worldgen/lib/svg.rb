require 'rvg/rvg'
include Magick

class SvgOutput<WorldGenerator
  @@pi = Math::PI.round(5)
  def initialize(filename)
    @rows     = 40
    @columns  = 32
    @source_filename = filename
    @svg_filename    = filename.gsub(File.extname(filename), '.svg')
    @side    = 40
    @factor  = 1.732
    @height  = (@side * @factor * (@rows + 0.5)).ceil
    @width   = (@side * (@columns * 1.5 + 0.5)).ceil
    @mark    = 13
    @zones   = []
    @volumes = []
    
    base03  = '#002b36'
    base02  = '#073642'
    base01  = '#586e75'
    base00  = '#657b83'
    base0   = '#839496'
    base1   = '#93a1a1'
    base2   = '#eee8d5'
    base3   = '#fdf6e3'
    yellow  = '#b58900'
    orange  = '#cb4b16'
    red     = '#dc322f'
    magenta = '#d33682'
    violet  = '#6c71c4'
    blue    = '#268bd2'
    cyan    = '#2aa198'
    green   = '#859900'
    white   = '#FFFFFF'
    black   = '#222222'
    
    @theme = {
      'dark' => {
        :background => base03,
        :zone       => {'AZ' => yellow, 'RZ' => red},
        :hex        => base1,
        :hex_id     => base2,
        :world_text => base2,
        :black      => base3,
        :base02     => base2,
        :base1      => base01,
        :white      => white,
        :tract_id   => base01
      },
      'lite' => {
        :background => white,
        :zone       => {'AZ' => yellow, 'RZ' => red},
        :hex        => base1,
        :hex_id     => base01,
        :world_text => base01,
        :black      => black,
        :base02     => base02,
        :base1      => base1,
        :white      => white,
        :tract_id   => base2
      }
    }
    theme = (%w{lite dark}.include?(@@config['svg_theme'])) ? @@config['svg_theme'] : 'lite'
    @color = @theme[theme]
    @hex = {
      :side_h => (@side * (@factor / 2)).tweak,
      :side_w => (@side / 2).tweak,
      :width  => @side
    }
    @style = {
      :circle    => "fill='#{@color[:black]}' stroke='#{@color[:white]}' stroke-width='1'",
      :polyline  => "fill='none'",
      :polygon   => "fill='#{@color[:black]}' stroke='none' stroke-width='1'",
      :ellipse   => "fill='none' stroke='#{@color[:base02]}' stroke-width='1'",
      :Belt      => "stroke='#{@color[:white]}' stroke-width='1'",
      :AZ_zone   => "fill='none' stroke='#{@color[:zone]['AZ']}' stroke-width='3' stroke-dasharray='5%,5%'",
      :RZ_zone   => "fill='none' stroke='#{@color[:zone]['RZ']}' stroke-width='3'",
      :Planet    => "fill='#{@color[:black]}' stroke='#{@color[:black]}' stroke-width='1'",
      :Desert    => "fill='none' stroke='#{@color[:black]}' stroke-width='2'",
      :Frame     => "fill='none' stroke='#{@color[:black]}' stroke-width='4'",
      :Tract     => "fill='none' stroke='#{@color[:hex]}' stroke-width='1'",
      :Hexgrid   => "fill='none' stroke='#{@color[:hex]}' stroke-width='1'",
      :Name      => "text-anchor='middle' font-size='#{@side/5}px' fill='#{@color[:world_text]}' font-family='Verdana'",
      :symbol    => "text-anchor='middle' font-size='#{@side/2.5}px' fill='#{@color[:black]}' font-family='Verdana'",
      :Spaceport => "text-anchor='middle' font-size='#{@side/3}px' fill='#{@color[:world_text]}' font-family='Verdana'",
      :TractID   => "text-anchor='middle' font-size='#{@side*3}px' fill='#{@color[:tract_id]}' font-family='Verdana'",
      :VolumeId  => "text-anchor='middle' font-size='#{@side/5}px' fill='#{@color[:hex_id]}' font-family='Verdana'",
      :rect      => "fill='#{@color[:background]}'"
    }
    @style[:UWP] = @style[:Name]
  end
  def from_file
    File.open(@source_filename,'r').readlines.each { |line| @volumes << line if /^\d{4}/.match(line) }
  end
  def print
    from_file
    svg = []
    svg << header
    svg << tract_marks
    svg << hex_grid

    svg << @volumes.map {|v| world(v) }
    svg << volumes
    svg << frame
    svg << footer
    File.open(@svg_filename,'w').write(svg.flatten.join("\n"))
  end
  def footer
    return "</svg>"
  end
  def header
    return<<-EOS
<?xml version="1.0" standalone="no"?>
  <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
    "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="#{@width}px" height="#{@height}px" version="1.1" xmlns="http://www.w3.org/2000/svg" blackground-color='#{@color[:white]}'>
  <desc>Subsector Map Grid</desc>
  <rect #{@style[:rect]} width='#{@width}' height='#{@height}' />
    EOS

  end
  def center_of(locx)
    column = locx[0..1].to_i
    row    = locx[2..3].to_i
    x      = @side + ((column - 1) * @side * 1.5)
    y      = (row - 1) * @side * @factor + (@side * @factor / (1 + (column % 2)))
    return [x.tweak,y.tweak]
  end
  def star_coords(r1,r2,points)
    pangle = 2*@@pi/points
    sangle = @@pi/points
    oangle = @@pi/-2
    coords = []
    points.times do |j|
      coords << [r1 * Math::cos(pangle * j + oangle), r1 * Math::sin(pangle * j + oangle)]
      coords << [r2 * Math::cos((pangle * j) + sangle + oangle), r2 * Math::sin((pangle * j) + sangle + oangle)]
    end
    return coords
  end
  def world(volume)
    # TAB 0 - World Details
    # 0. Location
    # 1. UWP
    # 2. Temp
    # 3. NSG (Features)
    # 4. Travel Zone
    # TAB 1 - Trade Codes
    # TAB 2 - Factions
    # TAB 3 - Name
    #1101 A505223-B  ..G.. »·IC,Lo,Va       »N,O,N   »·G0V  »Omivarium
    details, trades, factions, star, name = volume.split(/\t/)    
    
    locx, uwp, temp, nsg, zone = details.split(/\s+/)

    spaceport = uwp[0]
    size      = uwp[1]
    c         = center_of(locx) # get Location's x,y Coordinates
    curve = @side / 2
    
    output =  "<!-- Volume: #{volume.strip.gsub(/\t/,' // ')} -->\n"
    output +=  (size == '0') ? draw_belt(c) : draw_planet(c,uwp)
    output += "    <text #{@style[:Spaceport]} x='#{c[0]}' y='#{(c[1] + @side / 2).tweak}'>#{spaceport.strip}</text>\n" 
    output += "    <text #{@style[:UWP]} x='#{c[0]}' y='#{(c[1]+(@side/1.3)).tweak}'>#{uwp.strip}</text>\n"
    output += "    <text #{@style[:Name]} x='#{c[0]}' y='#{(c[1]-(@side/2.1)).tweak}'>#{name.strip}</text>\n"
    unless zone == '..'
      style = zone + '_zone' 
      output += "    <path #{@style[style.to_sym]} d='M #{c[0] - curve/2;} #{c[1] - (curve/1.4)} a #{curve} #{curve} 0 1 0 20 0' />\n"
    end
    output += navy_base(c)  if nsg.include?('N')
    output += scout_base(c) if nsg.include?('S')
    output += gas_giant(c)  if nsg.include?('G')
    output += consulate(c)  if nsg.include?('C')
    output += pirates(c)    if nsg.include?('P')
    # output += "    <text #{@style[:Name]} x='#{(c[0]+(@side/1.8)).tweak}' y='#{(c[1]-(@side/3)).tweak}'>#{star[0..1].strip}</text>\n"
    output += stars(c,star)
    output
    
  end
  def stars(c,stars)
    output = ''
    x = (c[0]+(@side/1.8)).tweak + 2
    y = (c[1]-(@side/3)).tweak + 3
    stars.split('/').each do |star|
      output += "    <text #{@style[:Name]} x='#{x}' y='#{y}'>#{star[0..1].strip}</text>\n"
      x += 3
      y += 7
    end
    output
  end
  def draw_planet(c,w)
    k = (w[3] == '0') ? 'Desert' : 'Planet'
     "    <circle #{@style[:circle]} cx='#{c[0]}' cy='#{c[1]}' r='#{@side/7}' />\n"
  end
  def draw_belt(c)
    output = "    <g stroke='none' fill='none'>\n"
    7.times do 
      x = c[0] + Random.rand(@side/3) - @side/6
      y = c[1] + Random.rand(@side/3) - @side/6
      output += "      <circle #{@style[:Belt]} cx='#{x.tweak}' cy='#{y.tweak}' r='#{(@side/15).tweak}' />\n"
    end
    output + "    </g>\n"
  end
  def frame(k='Frame')
    style = k.to_sym
    z = 0; w = @width - 0; h = @height - z;
    "    <polyline #{@style[style]} points='#{z},#{z} #{w},#{z} #{w},#{h} #{z},#{h} #{z},#{z}' />"
  end
  def tract_marks
    height = (@height / 4).floor 
    width  = (@width / 4).ceil
    # width -= 2
    
    output = ''
    letters = ('A'..'P').to_a
    5.times do |r|
      h1 = (height.floor * r) - (8*r); h2 = h1 + height - 8
      w2 = 0
      4.times do |c|
        w1 = w2; w2 += (width - [-4,4,5,-4][c])
        output += "    <text #{@style[:TractID]} x='#{w1 + 70}' y='#{h1 + 110}'>#{letters.shift}</text>\n"
        output += "    <polyline #{@style[:Tract]} points='#{w1},#{h1} #{w2},#{h1} #{w2},#{h2} #{w1},#{h2} #{w1},#{h1}' />\n"
        # raise output
      end
    end
    return output
  end
  def volumes
    output = ''
    (@rows+2).times do |r|
      (@columns+1).times do |c|
        x = @side + ((c-1) * @side * 1.5)
        y = (c % 2 == 1) ? (r-1) * @side * @factor + (0.2 * @side) : (r-1) * @side * @factor + @hex[:side_h]+ (0.2 * @side)
        output += "<text #{@style[:VolumeId]} x='#{x.tweak}' y='#{y.tweak}'>%02d%02d</text>\n" % [c,r]
      end
    end
    output
  end
  def polygon(x, y, sx, sy, sides=4)
    polygon = star_coords(sx, sy, sides).map { |c| "#{x + c[0]},#{y.tweak+c[1]}" }
    "    <polygon #{@style[:polygon]} points='#{polygon.join(' ')}' />\n"
  end
  def gas_giant(c)
    x = (c[0]+(@side/1.8)).tweak; y = (c[1]+(@side/3)).tweak;
    return<<-GIANT
    <g><!-- Has Gas Giant -->
      <ellipse #{@style[:ellipse]} cx='#{x}' cy='#{y}' rx='#{(@side/(@mark * 0.5)).tweak}' ry='#{(@side/@mark * 0.3).tweak}' />
      <circle  #{@style[:circle]} cx='#{x}' cy='#{y}' r='#{(@side/(@mark * 1.2)).tweak}' />
    </g>
    GIANT
  end
  def pirates(c);
      return "<!-- Pirates --><text #{@style[:symbol]} x='#{c[0]-(@side/3.1)}' y='#{c[1]+(@side/7)}'>\u2620</text>\n"
  end
  def consulate(c);
      return "<!-- Consulate --><text #{@style[:symbol]} x='#{c[0]-(@side/1.5)}' y='#{c[1]+(@side/7)}'>\u2691</text>\n"
  end
  def scout_base(c);
      return "<!-- Scout Base --><text #{@style[:symbol]} x='#{c[0]-(@side/1.8)}' y='#{c[1]+(@side/2.4)}'>\u269C</text>\n"
    '<!-- SB -->' + polygon(c[0]-(@side/1.8),c[1]+(@side/3.7), @side/(@mark/2), @side/@mark, 3);
  end
  def navy_base(c); 
    return "<!-- Navy Base --><text #{@style[:symbol]} x='#{c[0]-(@side/1.8)}' y='#{c[1]-(@side/6)}'>\u2693</text>\n"
    '<!-- NB -->' +polygon(c[0]-(@side/1.8), c[1]-(@side/3.7), @side/(@mark/2), @side/@mark, 5); 
  end
  def hex_grid; (@rows * 3 + 2).times.map { |j| hex_row((j/2).floor, (j % 2 != 0)) }; 
  end
  def hex_row(row, top=false)
    ly = (row * 2 * @hex[:side_h]) + @hex[:side_h]
    points = []
    x = 0; y = 0
    (@columns/2).ceil.times do |j|
      x = j * @side * 3
      y = ly
      points << "#{x.tweak},#{y.tweak}"
      
      x += @hex[:side_w]
      y = (top) ? y - @hex[:side_h] : y + @hex[:side_h]
      points << "#{x.tweak},#{y.tweak}"
      
      x += @hex[:width]
      points << "#{x.tweak},#{y.tweak}"
      
      x += @hex[:side_w]
      y = (top) ? y + @hex[:side_h] : y - @hex[:side_h]
      points << "#{x.tweak},#{y.tweak}"
      
      x += @hex[:width]
      points << "#{x.tweak},#{y.tweak}"
    end
    x += @hex[:side_w]
    y = (top) ? y - @hex[:side_h] : y + @hex[:side_h]
    points << "#{x.tweak},#{y.tweak}"
    "    <polyline #{@style[:Hexgrid]} points='#{points.join(' ')}' />"
  end
end
