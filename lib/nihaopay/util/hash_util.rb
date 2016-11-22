# Emulates Hash methods from ActiveSupport without monkey-patching the Hash class directly.
module Nihaopay
  module HashUtil
    class << self
      def symbolize_keys(hash)
        result = {}
        hash.each_key do |key|
          result[(key.to_sym rescue key)] = hash[key]
        end
        result
      end

      def stringify_keys(hash)
        result = {}
        hash.each_key do |key|
          result[(key.to_s rescue key)] = hash[key]
        end
        result
      end

      def slice(hash, *keys)
        result = {}
        keys.each do |key|
          result[key] = hash[key] if hash.key?(key)
        end
        result
      end
    end
  end
end
