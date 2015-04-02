require "zensana/version"
require "thor"

class Zensana < Thor
  desc "help", "display some help text"
  def help
    puts "Is this helpful? No!"
  end
end
