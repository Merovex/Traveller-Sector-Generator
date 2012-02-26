require 'yaml'
require 'pathname'
require './worldgen/init'

desc "Convert Traveller output to SVG"
task :svg, :filename do |t,args| 
  filename = args[:filename] || Dir.entries('.').sort_by {|f| File.mtime(f)}.reverse.map{|x| x if (/\.sector$/).match(x)}.compact[0] if filename.nil?
  s = SvgOutput.new(filename)
  s.print
end

desc "Generate Traveller Sector"
task :worldgen, :sector_name do |t,args| 
  name = args[:sector_name]
  # raise name.inspect
  read_config
  s = Sector.new(name)#.generate
  s.generate!
  s.to_file
  # s.print
end
def read_config
  @config = YAML::load(IO.read('_config.yml'))
end
task :setup do
  @rolls = 6667.times.map { 1.d6 }
  File.open('pregen_rolls.yml','w').write( @rolls.to_yaml )
end