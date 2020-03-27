# frozen_string_literal: true

module MailProvider
  class Checker
    def initialize(path = nil, directory = nil)
      @manager = SourceManager.new path, directory
    end

    def setup(refresh: false)
      @manager.run(refresh: refresh)
      load_tries
      self
    rescue TrieLoadError
      raise if refresh

      setup refresh: true
    end

    def check(str, summarize: false)
      provided, domains, data = fetch_data_for(str, summarize: summarize)
      build_response provided, domains
      add_success data, :entry, provided.name
      add_success data, :subdomain, data.to_a[0][0], provided.domain
      add_success data, :domain, provided.domain
      @response
    end

    def get(str)
      func = ->(trie) { trie.get(str).to_i }
      { free: func.call(@free), disposable: func.call(@disposable) }
    end

    def map(m, *a, &b)
      { free: @free.send(m, *a, &b), disposable: @disposable.send(m, *a, &b) }
    end

    def method_missing(m, *a, &b)
      return map(m, *a, &b) if @free.respond_to?(m, true)

      super
    end

    def respond_to_missing?(m, *a)
      @free.respond_to?(m, *a) || super
    end

    private

    def fetch_data_for(str, summarize: false)
      provided, domains = extract_domains(str)
      domains = domains.map { |part| [part, get(part)] }
      domains = domains.select { |item| item.last.values.sum.positive? }
      data = summarize ? summarize_domain_parts(domains).to_h : domains.to_h
      [provided, domains, data]
    end

    def build_response(provided, domains)
      @response = {
        ascii: provided.name, found: domains.length,
        unicode: SimpleIDN.to_unicode(provided.name),
        domain: SimpleIDN.to_unicode(provided.domain),
        tld: SimpleIDN.to_unicode(provided.tld),
        data: domains.to_h, match: nil
      }
    end

    def add_success(data, match, key, check = nil)
      return if data.empty?
      return if @response[:match] || !data.key?(key)
      return if check && key == check

      @response.merge!(match: match)
      @response.merge!(data[key])
    end

    def load_tries
      @free = MailProvider::Trie.load :free, directory: @manager.directory
      @disposable = MailProvider::Trie.load :disposable, directory: @manager.directory
    end

    def extract_domains(str)
      domain = SimpleIDN.to_ascii(str.split('@').last)
      domain = PublicSuffix.parse(domain)

      parts = domain.trd ? domain.trd.split('.') : []
      parts = parts.map.with_index { |_, i| parts[i..-1].join('.') }
      parts = parts.map { |i| "#{i}.#{domain.domain}" } << domain.domain
      [domain, parts]
    end

    def summarize_domain_parts(parts)
      data = []
      parts.reverse.each.with_index do |item, idx|
        data << [item[0], item[1].dup]
        if idx.positive? && data[idx][0].end_with?(data[idx - 1][0])
          data[idx][1][:free] += data[idx - 1][1][:free].to_i
          data[idx][1][:disposable] += data[idx - 1][1][:disposable].to_i
        end
      end
      data.reverse
    end
  end
end
