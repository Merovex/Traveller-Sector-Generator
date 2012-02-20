require 'yaml'
require './worldgen/init'

task :worldgen do 
  read_config
  s = Sector.new
  s.generate
end
def read_config
  @config = YAML::load(IO.read('_config.yml'))
end
task :setup do
  @rolls = 2000.times.map { 1.d6 }
  File.open('pregen_rolls.yml','w').write( @rolls.to_yaml )
end