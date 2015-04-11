module Zensana
  class Zendesk
    class Attachment
      include Zensana::Zendesk::Access

      attr_reader :attributes

      def initialize
        @attributes = {}
      end

      def upload(filename)
        @attributes = upload_file(filename)
      end

      def method_missing(name, *args, &block)
        attributes[name.to_s] || super
      end

      private

      def upload_file(file)
        raise NotFound, "#{file} does not exist" unless File.exist?(file)
        zendesk_service.create(
          "/uploads.json",
          :headers => {
            "Content-Type" => "application/binary"
          },
          :detect_mime_type => true,
          :body => {
            "filename"      => "#{File.basename(file)}",
            "uploaded_data" => File.new(file)
          },
          )['upload']
      end
    end
  end
end