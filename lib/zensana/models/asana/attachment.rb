module Zensana
  class Asana
    class Attachment
      include Zensana::Asana::Access

      attr_reader :attributes

      def initialize(id)
        @attributes = fetch(id)
      end

      def download
        FileUtils.mkdir_p file_dir
        File.open(full_path, "wb") do |f|
          f.write HTTParty.get(self.download_url).parsed_response
        end
      end

      def full_path
        "#{file_dir}/#{self.name}"
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end

      private

      def file_dir
        "/tmp/zensana/#{parent}"
      end

      def parent
        self.parent['id']
      end

      def fetch(id)
        asana_service.fetch("/attachments/#{id}")
      end
    end
  end
end
