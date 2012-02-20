require 'rvg/rvg'
include Magick

class SvgMapMaker
  @@pi = Math::PI.round(5)
  def initialize()
    @side    = 40
    @factor  = 1.732
    @height  = (@side * @factor * 10.5).ceil
    @width   = (@side * 12.5).ceil
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
    
    @color = {
      :zone       => {'AZ' => yellow, 'RZ' => red},
      :hex        => base1,
      :hex_id     => base01,
      :world_text => base01,
      :black      => black,
      :base02     => base02,
      :base1      => base1,
      :white      => base3
    }
    @hex = {
      :side_h => (@side * (@factor / 2)).tweak,
      :side_w => (@side / 2).tweak,
      :width  => @side
    }
    @stroke = {
      :zone => {'AZ' => '1%,1%', 'RZ' => '%3,%3'}
    }
    from_file
  end
  def from_file
    text=<<-TEXT
 subsector Havana
sector Transit

0104 A000512-G N.G	Diego
0107 B454632-9 N.G	Armistice
0109 B646521-A ..G	Biendah
0201 D855498-2 .SG	Hardscrabble
0202 C544677-6 ..G	Mandinka
0205 D698413-6 .S.	Sierra Pasos
0206 E652378-4 NSG	LaGrange
0207 C576545-8 ..G	Tabula
0208 E447667-3 ..G	Mesa
0210 B3107CA-A ..G	Hosanna
0304 C147630-7 ..G	Carnastra
0310 B223AAD-G ..G	Politzania
0406 B224633-A ...	Teg
0407 C410254-7 .SG	Calan Tria
0408 B3009DG-A N.G	Gasp
0409 C141657-6 .SG	New Manifold
0502 B877549-9 ..G	Tarsus
0504 C210524-8 .SG	Quench
0508 A430320-D N.G	Gulch
0509 B746322-8 ..G	Grisas
0510 C68A301-9 ..G	Kli
0603 E344596-4 ..G	Grit
0609 A9A7344-9 .SG	Sunder
0704 A542451-B ..G	Tomas
0706 B020355-D N.G	Pocket
0802 B400215-B ..G	Black
0807 A589885-9 ..G	Breadbasket
0808 C9B8455-7 ..G	Aerie
0809 A400133-B .SG	Domiere

AZ 0310
AZ 0208
AZ 0206
RZ 0603

J1 0104 0406 0508 0807
J2 0406 0706 0704 0802
    TEXT
    
    # lines = text.split(/\n/)
    lines = File.open('sectors/opera.sector.txt','r').readlines
    # raise lines.inspect
    lines.each do |line|
      # last if 
      case
      when /^\d{4}/.match(line) then
        @volumes << line.split(/\t/)
      when /^(A|R)Z/.match(line) then 
        @zones << line
      end
    end
    
  end
  def print
    puts header
    puts hex_grid
    puts travel_warnings
    puts @volumes.map {|v| world(v) }
    puts volumes
    puts frame
    puts footer    
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
    <style type="text/css"><![CDATA[
        circle          { fill: #{@color[:black]}; stroke: #{@color[:white]}; stroke-width: 1; }
        polyline        { fill: none; }
        polygon         { fill: #{@color[:black]}; stroke: none; stroke-width:1;}
        ellipse         { fill: none; stroke: #{@color[:base02]}; stroke-width:1;}
        text            { fill: #{@color[:world_text]}; font-size: #{@side/5}px; font-family: Sans-Serif; text-anchor: middle; }
        .Belt           { stroke: #{@color[:white]}; stroke-width: 1}
        .AZ_zone        { fill: none; stroke: #{@color[:zone]['AZ']}; stroke-width:3; stroke-dasharray:2%,0.5% }
        .RZ_zone        { fill: none; stroke: #{@color[:zone]['RZ']}; stroke-width:3;  }
        .Planet         { fill: #{@color[:black]}; stroke: #{@color[:black]}; stroke-width: 1; }
        .Desert         { fill: none; stroke: #{@color[:black]}; stroke-width: 2; }
        polyline.Frame  { fill: none; stroke: #{@color[:black]}; stroke-width:4; }
        polyline.Hexgrid{ fill: none; stroke: #{@color[:hex]}; stroke-width: 1;}
        text.Name       { font-family: Verdana;}
        text.Spaceport  { font-size: #{@side/3}px}
        text.VolumeId   { fill: #{@color[:hex_id]}}
        rect            { fill: red; width: 100%; height: 100%;}
      ]]></style>
    <rect />
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
    # First column: Hex/Column location in sector 
    # Second block: UWP code 
    # Third block: Trade codes 
    # Fourth block: Temperature code (0 = Extremes, 1 = Frozen, 2 = Cold, 3 = Temperate, 4 = Hot, 5 = Roasting). 
    # Fifth block: Gas giant Present (G = yes, blank = no)
    # locx, wo, nsg = volume[0].split(/\s+/)
    locx, uwp, trades, temp, nsg = volume[0].split(/\s+/)
    nsg = '' if (nsg.nil?)

    spaceport = uwp[0]
    size      = uwp[1].to_i
    c         = center_of(locx) # get Location's x,y Coordinates
    
    output = (size == 0) ? draw_belt(c) : draw_planet(c,uwp)
    output += "    <text class='Spaceport' x='#{c[0]}' y='#{c[1] + @side / 2}'>#{spaceport}</text>\n" 

    output += navy_base(c)  if nsg.include?('N')
    output += scout_base(c) if nsg.include?('S')
    output += gas_giant(c)  if nsg.include?('G')
    output += "<text class='Detail' fill='#{@color[:world_text]}' x='#{c[0]}' y='#{c[1]+(@side/1.3)}'>#{uwp}</text>\n"
    output += "<text class='Name'   fill='#{@color[:world_text]}' x='#{c[0]}' y='#{c[1]-(@side/2.1)}'>#{volume[1]}</text>\n"
    output
    
  end
  def draw_planet(c,w)
    k = (w[3] == '0') ? 'Desert' : 'Planet'
     "    <circle class='#{k}' cx='#{c[0]}' cy='#{c[1]}' r='#{@side/7}' />\n"
  end
  def draw_belt(c)
    output = "    <g stroke='none' fill='black'>\n"
    7.times do 
      x = c[0] + Random.rand(@side/3) - @side/6
      y = c[1] + Random.rand(@side/3) - @side/6
      output += "      <circle class='Belt' cx='#{x}' cy='#{y}' r='#{(@side/15).tweak}' />\n"
    end
    output + "    </g>\n"
  end
  def frame(k='Frame')
    z = 0; w = @width - 0; h = @height - z;
    "    <polyline class='#{k}' points='#{z},#{z} #{w},#{z} #{w},#{h} #{z},#{h} #{z},#{z}' />"
  end
  def volumes
    output = ''
    9.times do |c|
      12.times do |r|
        x = @side + ((c-1) * @side * 1.5)
        y = (c % 2 == 1) ? (r-1) * @side * @factor + (0.2 * @side) : (r-1) * @side * @factor + @hex[:side_h]+ (0.2 * @side)
        output += "<text class='VolumeId' x='#{x.tweak}' y='#{y.tweak}'>%02d%02d</text>\n" % [c,r]
      end
    end
    output
  end
  def travel_warnings()
    @zones.map do |z|
      zone, locx = z.split(/\s+/)
      c = center_of(locx)
      curve = @side / 2
      "<path class='#{zone}_zone' d='M #{c[0] - curve/2;} #{c[1] - (curve/1.4)} a #{curve} #{curve} 0 1 0 20 0' />"
    end
  end
  def polygon(x, y, sx, sy, sides=4)
    polygon = star_coords(sx, sy, sides).map { |c| "#{x + c[0]},#{y.tweak+c[1]}" }
    "    <polygon points='#{polygon.join(' ')}' />\n"
  end
  def gas_giant(c)
    x = c[0]+(@side/1.8); y = c[1]+(@side/3);
    return<<-GIANT
        <g>
          <ellipse cx='#{x}' cy='#{y}' rx='#{(@side/(@mark * 0.5)).tweak}' ry='#{(@side/@mark * 0.3).tweak}' />
          <circle  cx='#{x}' cy='#{y}' r='#{(@side/(@mark * 1.2)).tweak}' />
        </g>
    GIANT
  end
  def scout_base(c); '<!--SB -->' + polygon(c[0]-(@side/1.8),c[1]+(@side/3.7), @side/(@mark/2), @side/@mark, 3); end
  def navy_base(c); '<!--NB -->' +polygon(c[0]-(@side/1.8), c[1]-(@side/3.7), @side/(@mark/2), @side/@mark, 5); end
  def hex_grid; (@side / 2 + 2).times.map { |j| hex_row((j/2).floor, (j % 2 != 0)) }; end
  def hex_row(row, top=false)
    ly = (row * 2 * @hex[:side_h]) + @hex[:side_h]
    points = []
    x = 0; y = 0
    4.times do |j|
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
    "    <polyline class='Hexgrid' points='#{points.join(' ')}' />"
  end
end
