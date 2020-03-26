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
      provided, domains = extract_domains(str)
      domains = domains.map { |part| [part, get(part)] }
      checked = domains.length
      domains = domains.select { |item| item.last.values.sum.positive? }
      data = summarize ? summarize_domain_parts(domains).to_h : domains.to_h

      info = { provided: provided.name, summarize: summarize, total: checked,
               success: true, unicode: SimpleIDN.to_unicode(provided.name) }
      return info.merge(reason: :not_found, success: false) if data.empty?

      add_success info, :found, data[provided.name], data.key?(provided.name)
      add_success info, :domain_found, data[provided.domain], data.key?(provided.domain)
      add_success info, :subdomain_found, data.to_a[0][1], true
      info.merge(extra: domains.to_h)
    end

    def add_success(info, reason, item, condition)
      return if info[:reason] || !condition

      info.merge!(reason: reason)
      info.merge!(item)
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
