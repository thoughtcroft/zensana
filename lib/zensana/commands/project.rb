module Zensana
  class Command::Project < Zensana::Command

    desc 'find NAME', 'list projects that match NAME (regular expression supported)'
    def find(name)
      results = Zensana::Asana::Project.search(name).collect do |project|
        project['name']
      end
      puts results.sort
    end

    desc 'convert PROJECT', 'convert PROJECT tasks to ZenDesk tickets (by ID or NAME)'
    def convert(project)
      candidates = Zensana::Asana::Project.search(project)
      puts select_project(candidates)
    end

    private

    def select_project(array)
      return array.first['id'] if array.size == 1

      str_format   = "\n %#{array.count.to_s.size}s: %s"
      question     = set_color "\nWhich project should I use?", :yellow
      answers      = {}

      array.sort_by { |e| e['name'] }.each_with_index do |project, index|
        i = (index + 1).to_s
        answers[i] = project['id']
        question << format(str_format, i, project['name'])
      end

      puts question
      reply = ask("> ").to_s
      if answers[reply]
        answers[reply]
      else
        say "Not a valid selection, I'm out of here!", :red
        exit 1
      end
    end
  end
end
