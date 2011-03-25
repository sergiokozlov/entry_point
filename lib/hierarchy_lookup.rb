require 'Yaml'

module HierarchyLookup

  HRH_DIR = File.dirname(__FILE__) + "/../public/hierarchy"
  
  def self.lookup_table
    File.open(HRH_DIR+"/enkata_lookup.yml") do |file|
      return  hsh = YAML::load(file)
    end 
  end
  
  def self.lookup(name)
    h = HierarchyLookup.lookup_table
    h[name] || name
  end
end
