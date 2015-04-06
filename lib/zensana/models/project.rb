module Zensana
  class Project
    include Zensana::Asana::Access

    attr_reader :attributes

    def self.list
      @list ||= asana_host.fetch '/projects'
    end

    def initialize(spec)
      @attributes = fetch(spec)
    end

    def tasks
      @tasks ||= fetch_tasks(self.id)
    end

    def method_missing(name, *args, &block)
      attributes[name.to_s] || super
    end

    private

    def fetch(spec)
      if spec.is_a?(Fixnum)
        fetch_by_id(spec)
      else
        fetch_by_name(spec)
      end
    end

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
      task_list(id).map { |t| Zensana::Task.new(t['id']) }
    end

    def task_list(id)
      asana_host.fetch "/projects/#{id}/tasks"
    rescue NotFound
      nil
    end
  end
end
