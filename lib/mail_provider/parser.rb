# frozen_string_literal: true

module MailProvider
  class Parser
    FAMOUS_CHECKS = {
      free: %w[gmail.com hotmail.com outlook.com yahoo.com],
      disposable: %w[mailinator.com temp-mail.ru maildrop.cc 10minutemail.com]
    }.freeze

    def self.parse(sources)
      parser = new
      sources.each do |key, path|
        parser.add key, path
      end
      parser.data
    end

    attr_reader :key, :path

    def initialize
      @data = { free: [], disposable: [], unknown: [] }
    end

    def add(key, path)
      @key = key
      @path = path

      domains = read_domains_from_source
      type = categorize_source domains
      @data[type] << domains
    end

    def data
      @data.map do |type, items|
        items = items.flatten.group_by(&:itself)
        items = items.map { |k, v| [k, v.count] }
        items = items.sort_by { |r| r[1] }.reverse
        [type, items.to_h]
      end.to_h.slice(:free, :disposable)
    end

    protected

    def read_domains_from_source
      domains = File.readlines(@path)
      if domains.length == 1
        domains = domains.map do |line|
          line.split(',')
        end.flatten
      end

      domains.map { |d| sanitize_domain(d) }.compact.uniq
    end

    def sanitize_domain(domain)
      domain = SimpleIDN.to_ascii(domain.strip)
      return if domain.empty? || domain =~ /\A\#/

      domain = domain.gsub(/\A(www|)\./, '')
      PublicSuffix.parse(domain).name
    rescue PublicSuffix::DomainNotAllowed
      nil
    end

    def categorize_source(domains)
      types = []
      FAMOUS_CHECKS.each do |type, checks|
        checks.each do |domain|
          types << type if domains.include?(domain)
        end
      end

      return types[0] if types.uniq.length == 1

      puts "-> Ignoring Source: #{@key}"
      :unknown
    end
  end
end
