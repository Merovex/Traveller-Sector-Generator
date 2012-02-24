class Sector<WorldGenerator
  attr_accessor :volumes
  def initialize(name=nil)
    @name = name || WorldGenerator.getname
    @volumes = []
  end
  def to_s
    puts "SECTOR '#{@name}'\n"
    # puts @volumes
    filename = @name.downcase + '.sector'
    # puts filename
    File.open(filename,'w').write(@volumes.join("\n"))
  end
  def generate
    40.times do |r|
      32.times do |c|
        next unless has_system?
        v = Volume.new(c+1,r+1) 
        @volumes << v unless v.empty?
      end
    end
  end
end