require 'httparty'

module Zensana
  class Zendesk
    include HTTParty
    headers 'Content-Type' => 'application/json'
    default_timeout 10

    def self.inst
      @inst ||= new
    end

    module Access
      def zendesk_service
        @zendesk_service ||= Zensana::Zendesk.inst
      end
    end

    def initialize
      self.class.base_uri "https://#{ENV['ZENDESK_DOMAIN']}.zendesk.com/api/v2"
      self.class.basic_auth ENV['ZENDESK_USERNAME'], ENV['ZENDESK_PASSWORD']
    end

    def fetch(path, options={}, &block)
      request :get, path, options, &block
    end

    def request(method, path, options={}, &block)
      path = "#{path}.json" unless path.include?('json')
      result = self.class.send(method, path, options)

      Zensana::Error.handle_http_errors result

      Zensana::Response.new(result).tap do |response|
        block.call(response) if block_given?
      end
    end
  end
end
