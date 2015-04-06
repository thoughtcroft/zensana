module Zensana
  class Task
    include Zensana::Asana::Access

    attr_reader :attributes

    def initialize(id)
      @attributes = fetch(id)
    end

    def subtasks
      @subtasks ||= fetch_subtasks(self.id)
    end

    def stories
      @stories ||= stories_list(self.id)
    end

    def method_missing(name, *args, &block)
      attributes[name.to_s] || super
    end

    private

    def fetch(id)
      asana_host.fetch("/tasks/#{id}")
    end

    def fetch_subtasks(id)
      subtask_list(id).map { |s| Zensana::Task.new(s['id']) }
    end

    def subtask_list(id)
      asana_host.fetch "/tasks/#{id}/subtasks"
    rescue NotFound
      nil
    end

    def stories_list(id)
      asana_host.fetch "/tasks/#{id}/stories"
    rescue NotFound
      nil
    end
  end
end
