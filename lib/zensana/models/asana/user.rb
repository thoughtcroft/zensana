module Zensana
  class Asana
    class User
      include Zensana::Asana::Access
      attr_reader :attributes

      def self.list
        @list ||= Zensana::Asana.inst.fetch '/users'
      end

      def initialize(id)
        @attributes = fetch(id)
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end

      private

      def fetch(id)
        asana_service.fetch("/users/#{id}")
      end
    end
  end
end
