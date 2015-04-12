module Zensana
  class Command::Project < Thor

    desc 'search NAME', 'list projects that match NAME (regular expression supported)'
    def find(name)
      print_in_columns Zensana::Asana::Project.search(name)
    end

  end
end
