require 'yaml'
require 'pathname'
require './worldgen/init'

desc "Convert Traveller output to SVG"
task :svg, :filename do |t,args| 
  filename = args[:filename] || Dir.entries('.').sort_by {|f| File.mtime(f)}.reverse.map{|x| x if (/\.sector$/).match(x)}.compact[0] if filename.nil?
  s = SvgOutput.new(filename)
  s.print
end
task :jpg, :filename do |t,args|
  
end

desc "Generate Traveller Sector"
task :sector, :sector_name do |t,args| 
  name = args[:sector_name]
  read_config
  s = Sector.new(name)
  s.generate!
  s.prename!
  s.to_file
  puts "Created Sector '#{s.name}'"
end
def read_config
  @config = YAML::load(IO.read('_config.yml'))
end
desc "Pregenerate Roles"
task :setup do
  @rolls = 100000.times.map { 1.d6 }
  File.open('pregen_rolls.yml','w+').write( @rolls.to_yaml )
end
task :rename do |t, args|
  filename = args[:filename] || Dir.entries('.').sort_by {|f| File.mtime(f)}.reverse.map{|x| x if (/\.sector$/).match(x)}.compact[0] if filename.nil?
  name = filename.split(".")[0]
  s = Sector.new(name)
  s.rename!
  # raise [s, filename, name].inspect
end