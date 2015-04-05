require 'json'

module Zensana
  class Response
    def initialize(http_response)
      @ok   = http_response.success?
      body  = JSON.parse(http_response.body) rescue {}
      @data = body['data'] || body
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
