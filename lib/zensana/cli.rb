module Zensana
  class Cli < Zensana::Command

    desc 'project SUBCOMMAND', 'perform actions on Asana projects'
    subcommand 'project', Project

  end
end
