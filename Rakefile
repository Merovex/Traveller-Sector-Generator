require 'yaml'
require './worldgen/init'

task :svg, :filename do |t,args| 
  s = SvgOutput.new(args[:filename])
  s.print
end
task :worldgen, :sector_name do |t,args| 
  name = args[:sector_name] || nil
  read_config
  s = Sector.new(name)
  s.generate
  puts s
end
def read_config
  @config = YAML::load(IO.read('_config.yml'))
end
task :setup do
  @rolls = 30000.times.map { 1.d6 }
  File.open('pregen_rolls.yml','w').write( @rolls.to_yaml )
end