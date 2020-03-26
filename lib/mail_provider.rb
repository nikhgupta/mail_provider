# frozen_string_literal: true

module MailProvider
  ROOT_DIR = File.dirname(File.dirname(__FILE__))

  class Error < StandardError; end
  class TrieLoadError < StandardError; end
end

require 'trie'
require 'faraday'
require 'digest/md5'
require 'simpleidn'
require 'public_suffix'

require 'mail_provider/version'
require 'mail_provider/trie'
require 'mail_provider/parser'
require 'mail_provider/source_manager'
require 'mail_provider/checker'

module MailProvider
  def self.new(refresh: false, sources: nil, data_directory: nil)
    checker = MailProvider::Checker.new sources, data_directory
    checker.setup refresh: refresh
  end
end
