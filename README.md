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

**This gem was written in a couple of hours, and the intention has been to
get this working first for a project I am working on. This gem still needs
refactoring to make the code more readable, tests, etc. PRs welcome :)**

## Features

- IDN/Punycode compatibility
- should be thread-safe - immutable Trie structure.
- really fast! Uses efficient Patricia Trie structure.
- checks all parts of subdomain for checking an entry
- provide your own sources for disposable/free domains list
- 74000+ disposable domains, 9000+ free domains pre-configured
- check email/domain for free or disposable email provider status

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
lib.check 'example@c.nut.emailfake.nut.cc'
# => {:ascii=>"c.nut.emailfake.nut.cc",
#     :found=>3,
#     :unicode=>"c.nut.emailfake.nut.cc",
#     :domain=>"nut.cc",
#     :tld=>"cc",
#     :match=>:entry,
#     :summarize=>false,
#     :free=>1,
#     :disposable=>3,
#     :score=>-0.0625,
#     :data=>{"c.nut.emailfake.nut.cc"=>{:free=>1, :disposable=>3},
#             "emailfake.nut.cc"=>{:free=>0, :disposable=>6},
#             "nut.cc"=>{:free=>1, :disposable=>10}},

lib.check "финские-вейдерсы-2019.рф"
# => {:ascii=>"xn----2019-iofqgcb4aasj1c8cik0c5k.xn--p1ai",
#     :found=>1,
#     :unicode=>"финские-вейдерсы-2019.рф",
#     :domain=>"финские-вейдерсы-2019.рф",
#     :tld=>"рф",
#     :data=>{"xn----2019-iofqgcb4aasj1c8cik0c5k.xn--p1ai"=>{:free=>0, :disposable=>1}},
#     :match=>:entry,
#     :score=>-0.0625,
#     :free=>0,
#     :disposable=>1}

# check an email for status while summing up scores for each step in domain
lib.check 'c.nut.emailfake.nut.cc', summarize: true
# => {:ascii=>"c.nut.emailfake.nut.cc",
#     :found=>3,
#     :unicode=>"c.nut.emailfake.nut.cc",
#     :domain=>"nut.cc",
#     :tld=>"cc",
#     :match=>:entry,
#     :summarize=>true,
#     :free=>2,
#     :disposable=>19,
#     :score=>-0.9375,
#     :data=>{"c.nut.emailfake.nut.cc"=>{:free=>1, :disposable=>3},
#             "emailfake.nut.cc"=>{:free=>0, :disposable=>6},
#             "nut.cc"=>{:free=>1, :disposable=>10}},

# check a domain for status
lib.check 'gmail.com'
# => {:ascii=>"gmail.com", :summarize=>false, :checked=>1, :found=>true, :unicode=>"gmail.com",
#     :score=>1.0,:free=>8, :disposable=>0, :data=>{"gmail.com"=>{:free=>8, :disposable=>0}}}

lib.check 'nick@codewithsense.com'
# => {:ascii=>"codewithsense.com", :found=>0, :unicode=>"codewithsense.com",
#     :domain=>"codewithsense.com", :tld=>"com", :data=>{}, :match=>nil,
#     :summarize=>false, :score=>nil}
```

## Explaination

In the above examples, `free` is the number of sources claiming that the
given domain/email is from a free email provider, `disposable` is the number
of sources claiming that the given domain/email is from a disposable email
provider.

`checked` is the number of domain parts checked for this email/domain for
entries present with us. For example, for domain `subsub.sub.root.co.in`, we
check the following strings in our records (giving us a total of 3):

- subsub.sub.root.co.in
- sub.root.co.in
- root.co.in

If `summarize` is `true`, counts for each domain parts are added starting
from root domain.

`score` is the percent of sources claiming the string to be a free provider
minus the percent of sources claiming the string to be a disposable provider.
This value is `nil` if the string is not found in our entries, otherwise a
value between `-1` and `1`.

## Custom sources

The above uses pre-configured list of sources. To use your own list of
sources, provide a file with one (url) line per source.

We check the lists for inclusion of `gmail.com` and `mailinator.com` and
other similar domains to decide what kind of emails they list. To improve
efficiency, only provide sources that list EITHER free OR disposable emails,
and not both.

Afterwards, you can do:

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
