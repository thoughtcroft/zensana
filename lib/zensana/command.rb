require 'thor'

module Zensana
  class Command < Thor
    desc "example", "an example task"
    def example
      puts "This is an example task!"
    end
  end
end
