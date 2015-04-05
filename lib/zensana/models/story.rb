module Zensana
  class Story
    include Zensana::Asana::Access

    attr_reader :attributes

    def initialize(id)
      fetch(id)
    end

    def method_missing(name, *args, &block)
      attributes[name.to_s] || super
    end

    private

    def fetch(id)
      @attributes = asana_host.fetch("/stories/#{id}")
    end
  end
end
