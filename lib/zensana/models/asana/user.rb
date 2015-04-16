module Zensana
  class Asana
    class User
      include Zensana::Asana::Access

      def self.list
        @@list ||= Zensana::Asana.inst.fetch '/users'
      end

      attr_reader :attributes

      def initialize(id)
        @attributes = fetch(id)
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end

      private

      def fetch(id)
        if cache[id] then
          cache[id]
        else
          cache[id] = asana_service.fetch("/users/#{id}")
        end
      end

      def cache
        @@cache ||= {}
      end
    end
  end
end
