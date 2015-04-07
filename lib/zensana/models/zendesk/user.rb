module Zensana
  class Zendesk
    class User
      include Zensana::Zendesk::Access
      attr_reader :attributes

      def self.list
        @list ||= Zensana::Zendesk.inst.fetch '/users.json'
      end

      def initialize(id)
        @attributes = fetch(id)
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end

      private

      def fetch(id)
        zendesk_service.fetch("/users/#{id}.json")
      end
    end
  end
end
