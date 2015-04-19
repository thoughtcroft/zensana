module Zensana
  class Zendesk
    class Comment
      include Zensana::Validate::Key

      REQUIRED_KEYS = [ :author_id, :value ]
      OPTIONAL_KEYS = [ :created_at, :public, :uploads ]

      # Class validates the comment attributes
      # added during the Ticket Import call.
      # Comments cannot be created this way
      # for existing tickets.

      attr_reader :attributes

      def initialize(attributes)
        validate_keys attributes
        @attributes = attributes
      end

      def author_exists?(id)
        !! Zendesk::User.new.find(id)
      rescue NotFound
        false
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end
    end
  end
end
