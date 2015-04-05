module Zensana
  class Project
    include Zensana::Asana::Access

    attr_reader :attributes

    def initialize(spec=nil)
      @attributes = {}
      fetch(spec) if spec
    end

    def fetch(name)
      if name.is_a?(Fixnum)
        fetch_by_id(name)
      else
        fetch_by_name(name)
      end
    end

    def list
      @list ||= asana_host.fetch "/projects"
    end

    def method_missing(name, *args, &block)
      attributes[name.to_s] || super
    end

    def tasks
      raise ArgumentError, "Fetch a project first!" unless self.id
      asana_host.fetch "/projects/#{self.id}/tasks"
    end

    private

    def fetch_by_id(id)
      @attributes = asana_host.fetch("/projects/#{id}")
    end

    def fetch_by_name(name)
      list.each do |project|
        return fetch_by_id(project['id']) if project['name'] =~ %r{#{name}}
      end
      raise NotFound, "No project matches name '#{name}'"
    rescue RegexpError
      raise RegexpError, "'#{name}' is an invalid regular expression"
    end
  end
end
