module Zensana
  class Zendesk
    class Comment
      include Zensana::Validate::Key

      REQUIRED_KEYS = [ :author_id, :created_at, :value ]
      OPTIONAL_KEYS = [ :public, :attachments ]

      # Class validates the comment attributes
      # added during the Ticket Import call.
      # Comments cannot be created this way
      # for existing tickets.

      attr_reader :attributes

      def initialize(attributes)
        validate_keys attributes
        #id = attributes['author_id']
        #raise NotFound, "Author #{id} does not exist" unless author_exists?(id)
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
