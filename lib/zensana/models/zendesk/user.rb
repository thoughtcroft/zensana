require 'pry'

module Zensana
  class Zendesk
    class User
      include Zensana::Zendesk::Access

      attr_reader :attributes

      def initialize(spec=nil)
        fetch(spec) if spec
      end

      def fetch(spec)
        @attributes = spec.is_a?(Fixnum) ? fetch_by_id(spec) : fetch_by_name(spec)
      end

      def self.list
        # NOTE: this is a class variable so the list
        # is calculated only once for all instances
        @@list ||= [].tap do |users|
          zendesk_service.fetch('/users.json') do |response|
            while true
              users.concat response['users']
              break unless response.has_more_pages?
              response = zendesk_service.fetch(response.next_page)
            end
          end
        end
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end

      private

      def fetch_by_id(id)
        zendesk_service.fetch("/users/#{id}.json")['user']
      end

      def fetch_by_name(name)
        binding.pry
        self.list.each do |user|
          return fetch_by_id(user['id']) if user['name'] =~ %r{#{name}}
        end
        raise NotFound, "No user matches name '#{name}'"
      rescue RegexpError
        raise BadSearchSpec, "'#{name}' is not a valid regular expression"
      end
    end
  end
end
