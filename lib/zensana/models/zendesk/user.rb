require 'json'

module Zensana
  class Zendesk
    class User
      include Zensana::Zendesk::Access

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

      def initialize(attributes={})
        @attributes = attributes
      end

      def find(spec)
        @attributes = fetch(spec)
      end

      def create(attributes)
        name = attributes['name'] || attributes['user']['name']
        id   = id_from_list(name, false)
        raise AlreadyExists, "User '#{name}' already exists" if id
        @@list << @attributes = create_user(attributes)
        @attributes
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end

      private

      def fetch(spec)
        if spec.is_a?(Fixnum)
          fetch_by_id spec
        else
          fetch_by_name spec
        end
      end

      def fetch_by_id(id)
        zendesk_service.fetch("/users/#{id}.json")['user']
      end

      def fetch_by_name(name)
        id = id_from_list(name)
        raise NotFound, "No user matches name '#{name}'" unless id
        fetch_by_id id
      end

      def id_from_list(name, fuzzy=true)
        name_id = nil
        self.class.list.each do |user|
          if user['name'] == name || ( fuzzy && user['name'] =~ %r{#{name}} )
            name_id = user['id']
            break
          end
        end
        name_id
      rescue RegexpError
        raise BadSearch, "'#{name}' is not a valid regular expression"
      end

      def create_user(attributes)
        unless attributes['user'].is_a?(Hash)
          attributes = { 'user' => attributes }
        end
        zendesk_service.create("/users.json", :body => JSON.generate(attributes))['user']
      end
    end
  end
end
