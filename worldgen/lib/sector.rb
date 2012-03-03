class Sector<WorldGenerator
  attr_accessor :volumes, :name
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
  def prename!
    prename_file = @name + '.names'
    lines = File.open(prename_file,'r').readlines.map{|l| l.strip} if File.exist?(prename_file).inspect
    # raise names.inspect
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