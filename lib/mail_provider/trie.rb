# frozen_string_literal: true

module MailProvider
  class Trie
    def self.create(name, entries, opts = {})
      new(name).tap do |trie|
        entries.each { |key, val| trie.put! key, val }
        trie.save opts[:directory]
      end
    end

    def self.load(name, opts = {})
      new(name).tap do |trie|
        trie.load opts[:directory]
      end
    end

    def self.base_for(name, directory)
      File.join(directory, "#{name}.dump")
    end

    attr_reader :name

    def initialize(name)
      @name = name
      @native = Hamster::Trie.new(0)
    end

    def entries_where
      selected = []
      @native.each { |en| selected << en if !block_given? || yield(en[0]) }
      selected.sort_by(&:last).to_h
    end
    alias entries entries_where

    def matching(regex)
      entries { |en| en =~ regex }
    end

    def ending_with(str)
      entries { |en| en.end_with?(str) }
    end

    def starting_with(str)
      entries { |en| en.start_with?(str) }
    end

    def load(directory)
      base = self.class.base_for(@name, directory)
      unless File.exist?(base)
        raise TrieLoadError, "Saved trie does not exist at: #{base}"
      end

      @native = Hamster::Trie[Marshal.load(File.read(base))]
    end

    def save(directory)
      base = self.class.base_for(@name, directory)
      File.open(base, 'wb') { |f| f.write Marshal.dump(entries) }
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
