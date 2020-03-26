# frozen_string_literal: true

module MailProvider
  class SourceManager
    attr_reader :path, :directory, :total

    def initialize(path = nil, directory = nil)
      @path = path || File.join(MailProvider::ROOT_DIR, 'sources.txt')
      @directory = directory || File.join(MailProvider::ROOT_DIR, 'sources')
      @missing = unavailable_sources
    end

    def run(refresh: false)
      @missing = refresh ? sources : unavailable_sources
      download
      save

      sources # fetch sources again to update total count
    end

    protected

    def download
      return if @missing.empty?

      @missing.each do |key, url|
        puts "-> Downloading source: #{url}"
        body = Faraday.get(url).body
        File.open(File.join(@directory, "#{key}.txt"), 'w') { |f| f.puts body }
      end
    end

    def save
      return if @missing.empty?

      data = MailProvider::Parser.parse available_sources
      puts "-> free: #{data[:free].count}, disposable: #{data[:disposable].count}"
      MailProvider::Trie.create :free, data[:free], directory: @directory
      MailProvider::Trie.create :disposable, data[:disposable], directory: @directory
    end

    private

    def sources
      urls = File.readlines(@path).map(&:strip).reject { |line| line =~ /\A\#/ }
      data = urls.map { |url| [Digest::MD5.hexdigest(url), url] }.to_h
      @total = data.count
      data
    end

    def available_sources
      files = Dir.glob(File.join(@directory, '*.txt'))
      files = files.select { |f| File.readable?(f) }
      files.map { |file| [File.basename(file, '.txt'), file] }.to_h
    end

    def unavailable_sources
      available = available_sources
      sources.reject { |key, _| available.key?(key) }
    end
  end
end
