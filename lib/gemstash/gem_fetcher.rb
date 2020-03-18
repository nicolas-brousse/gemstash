# frozen_string_literal: true

require "gemstash"
require "set"

module Gemstash
  #:nodoc:
  class GemFetcher
    def initialize(http_client)
      @http_client = http_client
      @valid_headers = Set.new(%w[etag content-type content-length last-modified])
    end

    def fetch(gem_id, type, &block)
      @http_client.get(path_for(gem_id, type)) do |body, headers|
        properties = filter_headers(headers)
        validate_download(body, properties)
        yield body, properties
      end
    end

  private

    def path_for(gem_id, type)
      case type
      when :gem
        "gems/#{gem_id}"
      when :spec
        "quick/Marshal.4.8/#{gem_id}"
      else
        raise "Invalid type #{type.inspect}"
      end
    end

    def filter_headers(headers)
      headers.inject({}) do |properties, (key, value)|
        properties[key.downcase] = value if @valid_headers.include?(key.downcase)
        properties
      end
    end

    def validate_download(content, headers)
      expected_size = content_length(headers)
      raise "Incomplete download, only #{body.length} was downloaded out of #{expected_size}" \
        if content.length < expected_size
    end

    def content_length(headers)
      headers["content-length"].to_i
    end
  end
end
