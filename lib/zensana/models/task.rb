module Zensana
  class Task
    include Zensana::Asana::Access

    attr_reader :attributes

    def initialize(id)
      fetch(id)
    end

    def subtasks
      @subtasks ||= fetch_subtasks(self.id)
    end

    def stories
      @stories ||= fetch_stories(self.id)
    end

    def method_missing(name, *args, &block)
      attributes[name.to_s] || super
    end

    private

    def fetch(id)
      @attributes = asana_host.fetch("/tasks/#{id}")
    end

    def fetch_subtasks(id)
      list = []
      subtask_list(id).each do |subtask|
        list << Zensana::Task.new(subtask['id'])
      end
      list
    end

    def subtask_list(id)
      asana_host.fetch "/tasks/#{id}/subtasks"
    rescue NotFound
      nil
    end

    def fetch_stories(id)
      #list = []
      #stories_list(id).each do |story|
        #list << Zensana::Story.new(story['id'])
      #end
      #list
      stories_list(id)
    end

    def stories_list(id)
      asana_host.fetch "/tasks/#{id}/stories"
    rescue NotFound
      nil
    end
  end
end
