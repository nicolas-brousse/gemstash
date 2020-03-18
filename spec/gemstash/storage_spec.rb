# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe Gemstash::Storage do
  before do
    @folder = Dir.mktmpdir
  end
  after do
    FileUtils.remove_entry(@folder) if File.exist?(@folder)
  end

  it "stores metadata about Gemstash and the storage engine version" do
    expect(described_class.metadata[:storage_version]).to eq(described_class::VERSION)
    expect(described_class.metadata[:gemstash_version]).to eq(Gemstash::VERSION)
  end

  it "prevents using storage engine if the storage version is too new" do
    metadata = {
      storage_version: 999_999,
      gemstash_version: Gemstash::VERSION
    }

    File.write(Gemstash::Env.current.base_file("metadata.yml"), metadata.to_yaml)
    expect { Gemstash::Storage::LocalStorage.new(@folder) }.
      to raise_error(Gemstash::Storage::VersionTooNew, /#{Regexp.escape(@folder)}/)
  end
end
