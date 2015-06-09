module Zensana
  class Zendesk
    class Attachment
      include Zensana::Zendesk::Access

      MAX_ATTACHMENT_SIZE = 2*10**6

      attr_reader :attributes

      def initialize
        @attributes = {}
      end

      def upload(filename)
        @attributes = upload_file(filename)
      end

      def too_big?(file)
        File.size(file).to_f > MAX_ATTACHMENT_SIZE
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
          :detect_mime_type => mime_type_known?(file),
          :body => {
            "filename"      => "#{File.basename(file)}",
            "uploaded_data" => File.new(file)
          },
          )['upload']
      end

      def mime_type_known?(file)
        ! [ '.cshtml' ].include? File.extname(file)
      end
    end
  end
end
