module Zensana
  class MissingKeys < Error; end
  class UnknownKeys < Error; end

  module Validate
    module Keys
      def validate_keys(hash)
        raise MissingKeys, "You must supply #{required_keys}" unless has_required_keys?(hash)
        raise UnknownKeys, "Only #{valid_keys} are valid keys" if has_unknown_keys?(hash)
      end

      def has_required_keys?(hash)
        required_keys.all? { |k| hash.key? k }
      end

      def has_unknown_keys?(hash)
        (hash.keys - valid_keys).empty?
      end

      def valid_keys
        required_keys + optional_keys
      end

      def required_keys
        const_get :REQUIRED_KEYS
      end

      def optional_keys
        const_get :OPTIONAL_KEYS
      end
    end
  end
end
