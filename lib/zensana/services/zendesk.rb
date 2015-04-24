require 'httmultiparty'

module Zensana
  class Zendesk
    include HTTMultiParty
    default_timeout ( ENV['ZENSANA_TIMEOUT'] || 20 ).to_i
    #debug_output

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

    def fetch(path, params={}, &block)
      request :get, path, params, &block
    end

    def create(path, params={}, &block)
      request :post, path, params, &block
    end

    def request(method, path, params={}, &block)
      unless params[:headers]
        params[:headers] = {
          "Content-Type" => "application/json"
        }
      end
      path = relative_path(path)
      result = self.class.send(method, path, params)

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
