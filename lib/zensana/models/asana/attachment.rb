module Zensana
  class Asana
    class Attachment
      include Zensana::Asana::Access

      attr_reader :attributes

      def initialize(id)
        @attributes = fetch(id)
      end

      def download
        download_file unless downloaded?
      end

      def downloaded?
        File.exist? full_path
      end

      def full_path
        File.join(file_dir, attributes['name'])
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end

      private

      def file_dir
        File.join(temp_dir, 'downloads', parent)
      end

      def temp_dir
        ENV['ZENSANA_TEMP_DIR'] || '/tmp/zensana'
      end

      def parent
        attributes['parent']['id'].to_s
      end

      def fetch(id)
        asana_service.fetch("/attachments/#{id}")
      end

      def download_file
        FileUtils.mkdir_p file_dir
        result = File.open(full_path, "wb") do |f|
          f.write HTTParty.get(self.download_url)
        end

        Zensana::Error.handle_https result
        Zensana::Response.new(result).ok?
      end
    end
  end
end
