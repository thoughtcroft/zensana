module Zensana
  class Asana
    class Task
      include Zensana::Asana::Access

      attr_reader :attributes

      def initialize(id)
        @attributes = fetch(id)
      end

      def is_section?
        self.name.end_with?(':') rescue false
      end

      def subtasks
        @subtasks ||= fetch_subtasks(self.id)
      end

      def stories
        @stories ||= story_list(self.id)
      end

      def attachments
        @attachments ||= fetch_attachments(self.id)
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end

      private

      def fetch(id)
        asana_service.fetch("/tasks/#{id}")
      end

      def fetch_subtasks(id)
        subtask_list(id).map { |s| Zensana::Asana::Task.new(s['id']) }
      end

      def subtask_list(id)
        asana_service.fetch "/tasks/#{id}/subtasks"
      rescue NotFound
        nil
      end

      def fetch_attachments(id)
        attachment_list(id).map { |s| Zensana::Asana::Attachment.new(s['id']) }
      end

      def attachment_list(id)
        asana_service.fetch "/tasks/#{id}/attachments"
      rescue NotFound
        nil
      end

      def story_list(id)
        asana_service.fetch "/tasks/#{id}/stories"
      rescue NotFound
        nil
      end
    end
  end
end
