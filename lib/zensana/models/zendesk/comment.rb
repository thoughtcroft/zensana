module Zensana
  class Zendesk
    class Comment

      # This validates the comment attributes
      # added during the Ticket Import call.
      # Comments cannot be created this way
      # for existing tickets.

      attr_reader :attributes

      REQUIRED_KEYS = [ :author_id, :created_at, :value ]
      OPTIONAL_KEYS = [ :public, :attachments ]
      VALID_KEYS    = REQUIRED_KEYS + OPTIONAL_KEYS

      def initialize(attributes)
        @attributes = attributes
        raise ArgumentError, "You must supply #{REQUIRED_KEYS}" unless valid?
        raise ArgumentError, "Only #{VALID_KEYS} are valid keys" if unknown_keys?
        raise NotFound, "Author #{author_id} does not exist" unless author_exists?(author_id)
      end

      def required_keys?
        REQUIRED_KEYS.all? { |k| attributes.key? k }
      end

      def unknown_keys?
        (attributes.keys - VALID_KEYS).empty?
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
