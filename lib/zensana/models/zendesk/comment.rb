module Zensana
  class Zendesk
    class Comment
      include Zensana::Zendesk::Access

      # This is simply a way of organising the data
      # for adding comments during the Ticket Import
      # creation. Comments cannot be created this way
      # for normal tickets
      #
      # fields:
      #  id           (read-only)
      #  author_id    must exist
      #  value        'This is a comment'
      #  created_at   date
      #  public       true/false
      #  attachments  array of attachment hashes

      attr_reader :attributes

      def initialize(attributes)
        @attributes = attributes || {}
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end
    end
  end
end
