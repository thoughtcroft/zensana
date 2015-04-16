module Zensana
  class MissingKey    < Zensana::Error; end
  class UnknownKey    < Zensana::Error; end
  class UndefinedKeys < Zensana::Error; end

  module Validate
    module Key
      def validate_keys(hash)
        raise MissingKey, "Mandatory keys are: #{required_keys}" unless has_required_keys?(hash)
        raise UnknownKey, "Valid keys are: #{valid_keys}" if has_unknown_keys?(hash)
      end

      def has_required_keys?(hash)
        required_keys.all? { |k| hash.key? k }
      end

      def has_unknown_keys?(hash)
        ! (hash.keys - valid_keys).empty?
      end

      def valid_keys
        @valid_keys ||= required_keys + optional_keys
      end

      def required_keys
        @required_keys ||= begin
                             const = "#{self.class}::REQUIRED_KEYS"
                             Object.const_get const
                           rescue NameError
                             raise UndefinedKeys, "You must define #{const}"
                           end
      end

      def optional_keys
        @optional_keys ||= begin
                             const = "#{self.class}::OPTIONAL_KEYS"
                             Object.const_get const
                           rescue NameError
                             raise UndefinedKeys, "You must define #{const}"
                           end
      end
    end
  end
end
