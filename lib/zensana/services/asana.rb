require 'httparty'
require 'json'

module Zensana
  class Asana
    include HTTParty
    base_uri 'https://app.asana.com/api/1.0'
    default_timeout 5

    def initialize(user, pword)
      @auth = {username: user, password: pword}
    end

    def get(path, options={}, &block)
      request :get, path, options, &block
    end

    def request(method, path, params={}, &block)
      result = HTTParty.send(
        method,
        path,
        params.merge(
          :basic_auth => @auth,
          :headers => { 'Content-Type' => 'application/json' }
        )
      )

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
