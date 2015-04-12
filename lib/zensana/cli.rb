require 'thor'

module Zensana
  class Cli < Thor

    desc 'project SUBCOMMAND', 'perform actions on Asana projects'
    subcommand 'project', Zensana::Command::Project

  end
end
