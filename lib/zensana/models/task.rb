module Zensana
  class Task
    include Zensana::Asana::Access

    attr_reader :attributes

    def initialize(id)
      fetch(id)
      subtasks
    end

    def method_missing(name, *args, &block)
      attributes[name.to_s] || super
    end

    def subtasks
      @subtasks ||= begin
                      list = {}
                      subtask_list(self.id).each do |subtask|
                        list[subtask[id]] = Zensana::Task.new(subtask[id])
                      end
                      list
                    end
    end

    private

    def fetch(id)
      @attributes = asana_host.fetch("/tasks/#{id}")
    end

    def subtask_list(id)
      asana_host.fetch "/tasks/#{id}/subtasks"
    rescue NotFound
      nil
    end
  end
end
