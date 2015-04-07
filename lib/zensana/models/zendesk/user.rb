module Zensana
  class Zendesk
    class User
      include Zensana::Zendesk::Access
      attr_reader :attributes

      def self.list
        @list ||= Zensana::Zendesk.inst.fetch('/users.json')['users']
      end

      def initialize(spec)
        @attributes = fetch(spec)
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end

      private

      def fetch(spec)
        if spec.is_a?(Fixnum)
          fetch_by_id(spec)
        else
          fetch_by_name(spec)
        end
      end

      def fetch_by_id(id)
        zendesk_service.fetch("/users/#{id}.json")['user']
      end

      def fetch_by_name(name)
        list.each do |user|
          return fetch_by_id(user['id']) if user['name'] =~ %r{#{name}}
        end
        raise NotFound, "No user matches name '#{name}'"
      rescue RegexpError
        raise BadSearchSpec, "'#{name}' is not a valid regular expression"
      end
    end
  end
end
