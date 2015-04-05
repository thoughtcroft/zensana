require 'httparty'
require 'json'

module Zensana
  class Zendesk
    include HTTParty
    headers 'Content-Type' => 'application/json'
    default_timeout 10

    def self.inst
      @inst ||= new
    end

    module Access
      def zendesk_host
        @zendesk_host ||= Zensana::Zendesk.inst
      end
    end

    def initialize
      self.class.base_uri "https://#{ENV['ZENDESK_DOMAIN']}.zendesk.com/api/v2"
      self.class.basic_auth ENV['ZENDESK_USERNAME'], ENV['ZENDESK_PASSWORD']
    end

    def request(method, path, options={}, &block)
      result = self.class.send(method, path, options)

      Zensana::Error.handle_http_errors result

      Zensana::Response.new(result).tap do |response|
        block.call(response) if block_given?
      end
    end
  end
end
