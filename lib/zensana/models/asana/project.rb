module Zensana
  class Asana
    class Project
      include Zensana::Asana::Access

      def self.list
        # NOTE: this is a class variable so the list
        # is calculated only once for all instances
        @@list ||= Zensana::Asana.inst.fetch '/projects'
      end

      attr_reader :attributes

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
        asana_service.fetch("/projects/#{id}")
      end

      def fetch_by_name(name)
        self.class.list.each do |project|
          return fetch_by_id(project['id']) if project['name'] =~ %r{#{name}}
        end
        raise NotFound, "No project matches name '#{name}'"
      rescue RegexpError
        raise BadSearchSpec, "'#{name}' is not a valid regular expression"
      end

      def fetch_tasks(id)
        task_list(id).map { |t| Zensana::Task.new(t['id']) }
      end

      def task_list(id)
        asana_service.fetch "/projects/#{id}/tasks"
      rescue NotFound
        nil
      end
    end
  end
end
