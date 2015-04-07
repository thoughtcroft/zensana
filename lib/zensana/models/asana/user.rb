module Zensana
  class Asana
    class User
      include Zensana::Asana::Access

      def self.list
        # NOTE: this is a class variable so the list
        # is calculated only once for all instances
        @@list ||= Zensana::Asana.inst.fetch '/users'
      end

      attr_reader :attributes

      def initialize(id)
        @attributes = asana_service.fetch("/users/#{id}")
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end
    end
  end
end
