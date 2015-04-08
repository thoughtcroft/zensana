module Zensana
  class Asana
    class Attachment
      include Zensana::Asana::Access

      attr_reader :attributes

      def initialize(id)
        @attributes = asana_service.fetch("/attachments/#{id}")
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end
    end
  end
end
