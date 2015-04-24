module Zensana
  class Cli < Zensana::Command

    desc 'project SUBCOMMAND', 'perform actions on Asana projects'
    subcommand 'project', Project

    desc 'group SUBCOMMAND',   'perform actions on ZenDesk agent groups'
    subcommand 'group', Group

  end
end
