require 'json'

module Zensana
  class Zendesk
    class Ticket
      include Zensana::Zendesk::Access

      attr_reader :attributes

      def initialize(attributes)
        @attributes = attributes || {}
      end

      def find(id)
        @attributes = fetch(id)
      end

      def import(attributes=@attributes)
        raise AlreadyExists, "This ticket has already been imported with id #{self.id}" if imported?
        import_ticket(attributes)
      end

      def imported?
        !! id
      end

      def id
        attributes['id']
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end

      private

      def import_ticket(attributes)
        unless attributes['ticket']
          attributes = { 'ticket' => attributes }
        end
        zendesk_service.create(
          "/imports/tickets.json",
          :body => JSON.generate(attributes)
        )['ticket']
      end

      def fetch(id)
        zendesk_service.fetch("/tickets/#{id}.json")['ticket']
      end
    end
  end
end
