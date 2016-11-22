module Nihaopay

  # Emulates Hash methods from ActiveSupport without monkey-patching the Hash class directly.
  module HashUtil

    class << self

      def symbolize_keys(hash)
        _result = Hash.new
        hash.each_key do |key|
          _result[(key.to_sym rescue key)] = hash[key]
        end
        _result
      end

      def stringify_keys(hash)
        _result = Hash.new
        hash.each_key do |key|
          _result[(key.to_s rescue key)] = hash[key]
        end
        _result
      end

      def slice(hash, *keys)
        _result = Hash.new
        keys.each do |key|
          _result[key] = hash[key] if hash.has_key?(key)
        end
        _result
      end
    end
  end
end
