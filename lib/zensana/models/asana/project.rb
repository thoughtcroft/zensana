module Zensana
  class Asana
    class Project
      include Zensana::Asana::Access

      class << self

        def list
          @@list ||= Zensana::Asana.inst.fetch '/projects'
        end

        def search(spec)
          list.select { |p| p.to_s =~ %r{#{spec}} }
        rescue RegexpError
          raise BadSearch, "'#{spec}' is not a valid regular expression"
        end
      end

      attr_reader :attributes

      def initialize(spec)
        @attributes = fetch(spec)
      end

      def task_list
        @task_list ||= project_tasks
      end

      def full_tasks
        @full_tasks ||= fetch_project_tasks
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end

      private

      def list
        self.class.list
      end

      def id
        self.id
      end

      def fetch(spec)
        if is_integer?(spec)
          fetch_by_id(spec)
        else
          fetch_by_name(spec)
        end
      end

      def fetch_by_id(id)
        asana_service.fetch "/projects/#{id}"
      end

      def fetch_by_name(name)
        list.each do |project|
          return fetch_by_id(project['id']) if project['name'] =~ %r{#{name}}
        end
        raise NotFound, "No project matches name '#{name}'"
      rescue RegexpError
        raise BadSearch, "'#{name}' is not a valid regular expression"
      end

      def fetch_project_tasks
        task_list.map { |t| Zensana::Asana::Task.new(t['id']) }
      end

      def project_tasks
        asana_service.fetch "/projects/#{id}/tasks"
      rescue NotFound
        []
      end

      def is_integer?(id)
        Integer(id) rescue false
      end

    end
  end
end
