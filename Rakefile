require 'yaml'
require './worldgen/init'

task :worldgen do 
  read_config
  s = Sector.new
  x = s.d66
  raise x.inspect
  s.generate
  puts s.volumes
end
def read_config
  @config = YAML::load(IO.read('_config.yml'))
end
task :setup do
  @rolls = 30000.times.map { 1.d6 }
  File.open('pregen_rolls.yml','w').write( @rolls.to_yaml )
end