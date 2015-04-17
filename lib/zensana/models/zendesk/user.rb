require 'json'

module Zensana
  class Zendesk
    class User
      include Zensana::Zendesk::Access
      include Zensana::Validate::Key

      REQUIRED_KEYS = [ :name, :email ]
      OPTIONAL_KEYS = [ :time_zone, :locale_id, :organization_id, :role, :verified, :phone, :photo ]

      attr_reader :attributes

      def initialize
        @attributes = {}
      end

      def find(spec)
        @attributes = lookup(spec)
      end

      def create(attributes)
        validate_keys attributes
        email = attributes['email'] || attributes['user']['email']
        raise AlreadyExists, "User '#{email}' already exists" if lookup_by_email(email)
      rescue NotFound
        user = create_user(attributes)
        update_cache user
        @attributes = user
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end

      private

      def lookup(spec)
        if spec.is_a?(Fixnum)
          lookup_by_id spec
        else
          lookup_by_email spec
        end
      end

      def lookup_by_id(id)
        unless (user = read_cache(id))
          user = fetch(id)
          update_cache user
        end
        user
      end

      def lookup_by_email(email)
        unless (user = read_cache(email))
          if (user = search("email:#{email}"))
            update_cache user
          end
        end
        user
      end

      def create_user(attributes)
        unless attributes['user'].is_a?(Hash)
          attributes = { 'user' => attributes }
        end
        zendesk_service.create(
          "/users.json",
          :body => JSON.generate(attributes)
        )['user']
      end

      def cache
        @@cache ||= {}
      end

      def read_cache(key)
        cache[key.to_s]
      end

      def update_cache(user)
        [ 'id', 'email' ].each do |attr|
          key = user[attr].to_s
          cache[key] = user
        end
      end

      def fetch(id)
        zendesk_service.fetch("/users/#{id}.json")['user']
      end

      def search(query)
        zendesk_service.fetch("/users/search.json?query=#{query}")['users'].first
      end
    end
  end
end
