require 'json'

module Zensana
  class Zendesk
    class Ticket
      include Zensana::Zendesk::Access
      include Zensana::Validate::Key

      # if external_id is present for a ticket in
      # ZenDesk then we can say that it was already created
      def self.external_id_exists?(external_id)
        query = "/search.json?query=type:ticket,,external_id:#{external_id}"
        external_id && (result = Zensana::Zendesk.inst.fetch(query)['results']) &&
          ! (result.nil? || result.empty?)
      end

      REQUIRED_KEYS = [:requester_id ]
      OPTIONAL_KEYS = [
        :external_id, :type, :subject, :description, :priority, :status,
        :submitter_id, :assignee_id, :group_id, :collaborator_ids, :tags,
        :created_at, :updated_id, :comments, :solved_at, :updated_at
      ]

      attr_reader :attributes

      def initialize(attributes)
        @attributes = attributes || {}
      end

      def find(id)
        @attributes = fetch(id)
      end

      def import(attributes=@attributes)
        validate_keys attributes
        raise AlreadyExists, "This ticket has already been imported with id #{self.id}" if imported?
        import_ticket(attributes)
      end

      def imported?
        !! id
      end

      def id
        attributes['id']
      end

      def external_id
        attributes['external_id']
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
