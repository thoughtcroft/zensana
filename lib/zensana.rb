require "zensana/version"
require "thor"

class Zensana < Thor
  desc "import FILE", "What this command does"
  def import(file)
    puts "You want to import file #{file}"
  end
end
