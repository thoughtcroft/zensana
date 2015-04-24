module Zensana
  class Command::Group < Zensana::Command

    desc 'find GROUP', 'List ZenDesk Groups that match GROUP (by ID or NAME, regexp accepted)'
    def find(name)
      puts Zensana::Zendesk::Group.search(name).collect { |p| "#{p['id']}: #{p['name']}" }.sort
    end
  end
end
