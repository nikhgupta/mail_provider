# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mail_provider/version'

Gem::Specification.new do |spec|
  spec.name          = 'mail_provider'
  spec.version       = MailProvider::VERSION
  spec.authors       = ['nikhgupta']
  spec.email         = ['me@nikhgupta.com']

  spec.summary       = 'Smartly check whether a given email/domain belongs to a free or disposable mail provider.'
  spec.description   = <<-DESC
  Smartly check whether a given email/domain belongs to a free or disposable
  mail provider. There are hundreds of lists available in Github repositories
  or Gists that list various free and disposable email providers. This gem
  downloads a bunch of these scripts (pre-configured URLs) and parses them to
  count votes against each domain in the list. We, then, create a Trie
  structure to efficiently query this data with a given domain or email. For
  each query, you get back a number specifying how many sources are claiming
  that the domain is a free or disposable email provider.
  DESC
  spec.homepage      = 'https://github.com/nikhgupta/mail_provider'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_dependency 'faraday'
  spec.add_dependency 'fast_trie'
  spec.add_dependency 'public_suffix'
  spec.add_dependency 'simpleidn'
end
