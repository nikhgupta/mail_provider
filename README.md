# MailProvider

Smartly check whether a given email/domain belongs to a free or disposable
mail provider.

There are hundreds of lists available in Github repositories or Gists that
list various free and disposable email providers. This gem downloads a bunch
of these scripts (pre-configured URLs) and parses them to count votes against
each domain in the list. We, then, create a Trie structure to efficiently
query this data with a given domain or email. For each query, you get back a
number specifying how many sources are claiming that the domain is a free or
disposable email provider.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mail_provider'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install mail_provider
```

## Usage

In simple terms, you can do:

```ruby
# Re-download and update list of domains from sources
lib = MailProvider.new(refresh: true)

# Re-use cached/parsed list from the CSV in data-directory
lib = MailProvider.new(refresh: false)

# check an email for status
lib.check 'example@gmail.com'
# => { free: 19, disposable: 0, total: 20, maybe: :free, score: 0.95 }

# check a domain for status
lib.check 'gmail.com'
# => { free: 19, disposable: 0, total: 20, maybe: :free, score: 0.95 }
```

The above uses pre-configured list of sources. To use your own list of
sources, provide a file with one (url) line per source. You can do:

```ruby
MailProvider.new(sources: "<path-to-file>", refresh: true)
```

The gem saves the download and parsed list as a CSV in the gem's directory.
You can, optionally, provide a directory to save the parsed list in.

```ruby
MailProvider.new(data_directory: "<path-to-directory>")
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake spec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/nikhgupta/mail_provider. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](http://contributor-covenant.org) code of
conduct.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MailProvider project’s codebases, issue trackers,
chat rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/nikhgupta/mail_provider/blob/master/CODE_OF_CONDUCT.md).
