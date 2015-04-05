require 'httparty'
require 'json'

module Zensana
  class Asana
    include HTTParty
    base_uri 'https://app.asana.com/api/1.0'
    headers 'Content-Type' => 'application/json'
    default_timeout 10

    def self.inst
      @inst ||= new
    end

    module Access
      def asana_host
        @asana_host ||= Zensana::Asana.inst
      end
    end

    def initialize
      user, pword = if ENV['ASANA_USERNAME']
                      [ ENV['ASANA_USERNAME'], ENV['ASANA_PASSWORD'] ]
                    else
                      [ ENV['ASANA_API_KEY'], nil ]
                    end
      self.class.basic_auth user, pword
    end

    def fetch(path, options={}, &block)
      request :get, path, options, &block
    end

    def request(method, path, options={}, &block)
      result = self.class.send(method, path, options)

      Zensana::Error.handle_http_errors result

      Response.new(result).tap do |response|
        block.call(response) if block_given?
      end
    end

    class Response
      def initialize(http_response)
        @ok   = http_response.success?
        @data = JSON.parse(http_response.body)['data'] rescue {}
      end

      def ok?
        @ok
      end

      def [](key)
        @data.is_a?(Hash) ? @data[key.to_s] : key.is_a?(Integer) ? @data[key] : nil
      end

      def each(&block)
        @data.each(&block)
      end

      def to_h
        @data
      end

      def to_a
        @data
      end

      def to_s
        JSON.pretty_generate @data
      end
    end
  end
end
