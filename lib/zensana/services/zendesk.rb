require 'httparty'

module Zensana
  class Zendesk
    include HTTParty
    headers 'Content-Type' => 'application/json; charset=utf-8'
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

    def create(path, options={}, &block)
      request :post, path, options, &block
    end

    def request(method, path, options={}, &block)
      path = relative_path(path)
      result = self.class.send(method, path, options)

      Zensana::Error.handle_http_errors result

      Zensana::Response.new(result).tap do |response|
        block.call(response) if block_given?
      end
    end

    private

    def relative_path(path)
      path.sub(self.class.base_uri, '')
    end
  end
end
