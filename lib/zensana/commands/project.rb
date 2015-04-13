module Zensana
  class Command::Project < Zensana::Command

    desc 'find REGEXP', 'List projects that match REGEXP'
    def find(name)
      puts Zensana::Asana::Project.search(name).collect { |p| p['name'] }.sort
    end

    desc 'convert PROJECT', 'Convert PROJECT tasks to ZenDesk tickets (by ID or NAME)'
    def convert(project)
      say "This task will convert Asana project #{project} into ZenDesk tickets"
    end

    desc 'show PROJECT', 'Display details of PROJECT (choosing from list matching)'
    def show(project)
      candidates = Zensana::Asana::Project.search(project)

      if candidates.empty?
        say "\nNo project found matching '#{project}'", :red
      else
        result = select_project(candidates)
        candidate = Zensana::Asana::Project.new(result)
        puts candidate.attributes

        if yes? "\nShow first level task summary?", :yellow
          puts candidate.task_list
        end
      end
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
