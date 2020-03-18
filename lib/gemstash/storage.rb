# frozen_string_literal: true

require "gemstash"
require "digest"
require "fileutils"
require "pathname"
require "yaml"

module Gemstash
  # The entry point into the storage engine for storing cached gems, specs, and
  # private gems.
  class Storage
    extend Gemstash::Env::Helper
    VERSION = 1

    # If the storage engine detects the base cache directory was originally
    # initialized with a newer version, this error is thrown.
    class VersionTooNew < StandardError
      def initialize(folder, version)
        super("Gemstash storage version #{Gemstash::Storage::VERSION} does " \
              "not support version #{version} found at #{folder}")
      end
    end

    # Fetch a base entry in the storage engine.
    #
    # @param name [String] the name of the entry to load
    # @return [Gemstash::Storage] a new storage instance for the +name+
    def self.for(name)
      LocalStorage.new(gemstash_env.base_file(name))
    end

    # Read the global metadata for Gemstash and the storage engine. If the
    # metadata hasn't been stored yet, it will be created.
    #
    # @return [Hash] the metadata about Gemstash and the storage engine
    def self.metadata
      file = gemstash_env.base_file("metadata.yml")

      unless File.exist?(file)
        gemstash_env.atomic_write(file) do |f|
          f.write({ storage_version: Gemstash::Storage::VERSION,
                    gemstash_version: Gemstash::VERSION }.to_yaml)
        end
      end

      YAML.load_file(file)
    end

    def self.storage_service
      @storage_service ||= LocalStorage
    end
  end
end
