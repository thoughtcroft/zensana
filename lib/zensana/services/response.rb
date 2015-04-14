require 'awesome_print'

module Zensana
  class Response
    include Enumerable

    def each(&block)
      @data.each(&block)
    end

    def initialize(http_response)
      @ok   = http_response.success?
      body  = JSON.parse(http_response.body) rescue {}
      @data = body['data'] || body
    end

    def ok?
      @ok
    end

    def has_more_pages?
      !! next_page
    end

    def next_page
      @data['next_page']
    end

    def [](key)
      @data.is_a?(Hash) ? @data[key.to_s] : key.is_a?(Integer) ? @data[key] : nil
    end

    def to_h
      @data.respond_to?('to_h') ? @data.to_h : @data
    end

    def to_a
      @data.respond_to?('to_a') ? @data.to_a : @data
    end

    def to_s
      @data.respond_to?('to_s') ? @data.to_s : @data
    end

    def pretty
      ap @data
    end
  end
end
