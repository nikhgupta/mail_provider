# frozen_string_literal: true

module MailProvider
  class Trie
    def self.create(name, domains, opts = {})
      new(name).tap do |trie|
        trie.add domains
        trie.save opts[:directory]
      end
    end

    def self.load(name, opts = {})
      this = new name
      this.load opts[:directory]
      this
    end

    attr_reader :name, :directory, :native

    def initialize(name)
      @name = name
      @native = ::Trie.new
    end

    def add(domains)
      domains.each do |domain, weight|
        @native.add domain, weight
      end
    end

    def exists?(directory)
      base = File.join(directory, @name.to_s)
      File.exist?("#{base}.da") && File.exist?("#{base}.tail")
    end

    def load(directory)
      base = File.join(directory, @name.to_s)
      unless exists?(directory)
        raise TrieLoadError, "Saved trie does not exist at: #{base}.*"
      end

      @native = ::Trie.read(base)
    end

    def save(directory)
      base = File.join(directory, @name.to_s)
      @native.save base
    end

    def method_missing(m, *a, &b)
      return @native.send(m, *a, &b) if @native.respond_to?(m, true)

      super
    end

    def respond_to_missing?(m, *a, &b)
      @native.respond_to?(m, *a, &b) || super
    end
  end
end
