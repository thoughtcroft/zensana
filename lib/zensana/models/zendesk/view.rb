require 'json'

module Zensana
  class Zendesk
    class View
      include Zensana::Zendesk::Access

      attr_reader :attributes

      def initialize
        @attributes = {}
      end

      def find(id)
        @attributes = fetch(id)
      end

      def tickets
        raise NotFound, "You must fetch the view first!" unless self.id
        get_tickets self.id
      end

      def id
        attributes['id']
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end

      private

      def fetch(id)
        zendesk_service.fetch("/views/#{id}.json")['view']
      end

      def get_tickets(id)
        zendesk_service.fetch("/views/#{id}/tickets.json")['tickets']
      end
    end
  end
end
