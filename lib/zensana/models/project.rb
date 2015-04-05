module Zensana
  class Project
    include Zensana::Asana::Access

    attr_reader :attributes

    def initialize(spec=nil)
      fetch(spec) if spec
    end

    def fetch(name)
      @attributes = if name.is_a?(Fixnum)
                      fetch_by_id(name)
                    else
                      fetch_by_name(name)
                    end
    end

    def tasks
      @tasks ||= fetch_tasks(self.id)
    end

    def list
      @list ||= asana_host.fetch "/projects"
    end

    def method_missing(name, *args, &block)
      attributes[name.to_s] || super
    end

    private

    def fetch_by_id(id)
      asana_host.fetch("/projects/#{id}")
    end

    def fetch_by_name(name)
      list.each do |project|
        return fetch_by_id(project['id']) if project['name'] =~ %r{#{name}}
      end
      raise NotFound, "No project matches name '#{name}'"
    rescue RegexpError
      raise RegexpError, "'#{name}' is an invalid regular expression"
    end

    def fetch_tasks(id)
      list = []
      task_list(id).each do |task|
        list << Zensana::Task.new(task['id'])
      end
      list
    end

    def task_list(id)
      asana_host.fetch "/projects/#{id}/tasks"
    rescue NotFound
      nil
    end
  end
end
