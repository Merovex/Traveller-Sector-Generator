class Sector<WorldGenerator
  attr_accessor :volumes, :name
  require 'tempfile'
  require 'fileutils'
  def initialize(name=nil)
    @name = name || WorldGenerator.getname
    @volumes = []
  end
  def to_file
    filename = @name.downcase + '.sector'
    File.open(filename,'w').write(@volumes.map{|v| v.to_ascii}.join("\n"))
  end
  def generate!
    40.times do |r|
      32.times do |c|
        next unless has_system?
        v = Volume.new(c+1,r+1) 
        @volumes << v unless v.empty?
      end
    end
  end
  def getnames
    prename_file = @name.downcase + '.names'
    lines = []
    if File.exist?(prename_file)
      lines = File.open(prename_file,'r').readlines.map{|l| l.strip} 
    end
    return lines
  end
  def rename!
    filename = @name.downcase + '.sector'
    # raise filename.inspect
    names = {}
    getnames.map{|l| k,v = l.split; names[k] = v}
    sectors = names.keys
    lines = ""
    temp_file = Tempfile.new('foo')
    File.open(filename,'r').readlines.each do |line|
      if (/^\d{4}/.match(line))
        bits = line.chomp.split("\t")
        s = bits[0][0..3]
        if sectors.include?(s)
          bits[-1] = names[s]
          line = bits.join("\t")
        end
      end
      temp_file.puts line
    end
    temp_file.rewind
    FileUtils.mv(temp_file.path, filename)
    # File.open(new_file, 'w').write(lines)
  end
  def prename!
    # prename_file = @name.downcase + '.names'
    # lines = []
    # if File.exist?(prename_file)
    #   lines = File.open(prename_file,'r').readlines.map{|l| l.strip} 
    # end
    lines = getnames
    volumes = {}
    @volumes.each do |v|
      volumes["#{v.location}"] = v
    end
       
    lines.each do |l|
      volume_id, name, uwp = l.split(/\s+/)
      next if volume_id.nil? or volumes[volume_id].nil?
      volumes[volume_id].name = name unless name.nil?
      # raise [volume_id, name, uwp].inspect
    end
    @volumes = volumes.values
  end
end