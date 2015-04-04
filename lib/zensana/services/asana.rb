require 'httparty'
require 'json'

module Zensana
  class Asana
    include HTTParty
    base_uri 'https://app.asana.com/api/1.0'
    headers 'Content-Type' => 'application/json'
    default_timeout 10

    def initialize(user, pword)
      @auth = {username: user, password: pword}
    end

    def request(method, path, options={}, &block)
      options.merge!({:basic_auth => @auth})
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
    end
  end
end
