require 'json'

module Zensana
  class Zendesk
    class View
      include Zensana::Zendesk::Access

      attr_reader :attributes

      def initialize
        @attributes = {}
      end

      def list(active_only = true)
        fetch_list(active_only)
      end

      def find(id)
        @attributes = fetch_view(id)
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

      def fetch_view(id)
        zendesk_service.fetch("/views/#{id}.json")['view']
      end

      def fetch_list(active_only=true)
        url = active_only ? "/views/active.json/" : "/views.json"
        zendesk_service.fetch(url)['views']
      end

      def get_tickets(id)
        zendesk_service.fetch("/views/#{id}/tickets.json")['tickets']
      end
    end
  end
end
