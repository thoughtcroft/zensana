require 'json'

module Zensana
  class Zendesk
    class User
      include Zensana::Zendesk::Access
      include Zensana::Validate::Key

      REQUIRED_KEYS = [ :name, :email ]
      OPTIONAL_KEYS = [ :time_zone, :locale_id, :organization_id, :role, :verified, :phone, :photo ]

      def self.list
        # NOTE: this is a class variable so the list
        # is calculated only once for all instances
        @@list ||= [].tap do |users|
          service = Zensana::Zendesk.inst
          service.fetch('/users.json') do |response|
            while true
              users.concat response['users']
              break unless response.has_more_pages?
              response = service.fetch(response.next_page)
            end
          end
        end
      end

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
        @attributes = {}.tap do |user|
          user.merge! create_user(attributes)
          update_cache user
        end
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
        cache.each do |user|
          if user['id'] == id
            return user
          end
        end

        {}.tap do |user|
          user.merge! fetch(id)
          update_cache user
        end
      end

      def lookup_by_email(email)
        cache.each do |user|
          if user['email'] == email
            return user
          end
        end
        raise NotFound, "No user matches email '#{email}'"
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
        self.class.list
      end

      def update_cache(user)
        cache << user
      end

      def fetch(id)
        zendesk_service.fetch("/users/#{id}.json")['user']
      end
    end
  end
end
