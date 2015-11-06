module Zensana
  class Cli < Zensana::Command

    desc 'project SUBCOMMAND', 'perform actions on Asana projects'
    subcommand 'project', Project

    desc 'group SUBCOMMAND',   'perform actions on ZenDesk agent groups'
    subcommand 'group', Group

    desc 'view SUBCOMMAND',   'perform actions on ZenDesk views'
    subcommand 'view', View

  end
end
