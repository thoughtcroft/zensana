require 'httmultiparty'

module Zensana
  class Asana
    include HTTMultiParty
    base_uri 'https://app.asana.com/api/1.0'
    headers 'Content-Type' => 'application/json; charset=utf-8'
    default_timeout 10
    #debug_output

    def self.inst
      @inst ||= new
    end

    module Access
      def asana_service
        @asana_service ||= Zensana::Asana.inst
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

    def fetch(path, params={}, &block)
      request :get, path, params, &block
    end

    def request(method, path, params={}, &block)
      result = self.class.send(method, path, params)

      Zensana::Error.handle_http_errors result

      Zensana::Response.new(result).tap do |response|
        block.call(response) if block_given?
      end

    rescue Net::OpenTimeout
      raise Unprocessable, "Connection timed out"
    end

  end
end
