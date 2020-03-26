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

## Features

- check email/domain for free or disposable email provider status
- 74000+ disposable domains, 9000+ free domains pre-configured
- provide your own sources for disposable/free domains list
- checks all parts of subdomain for checking an entry
- IDN/Punycode compatibility
- really fast! uses Trie structures.

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
lib.check 'example@gmail.pp.au'
# => {:provided=>"subsub.sub.gmail.pp.ua", :summarize=>false, :success=>true,
#     :free=>1, :disposable=>2, :reason=>:domain_found, :unicode=>"gmail.pp.au",
#     :total=>1, :extra=>{"gmail.pp.ua"=>{:free=>1, :disposable=>2}}}

lib.check "финские-вейдерсы-2019.рф"
# => {:provided=>"xn----2019-iofqgcb4aasj1c8cik0c5k.xn--p1ai",
#     :summarize=>false,
#     :success=>true,
#     :unicode=>"финские-вейдерсы-2019.рф",
#     :reason=>:domain_found,
#     :total=>1,
#     :free=>0,
#     :disposable=>1,
#     :extra=>{"xn----2019-iofqgcb4aasj1c8cik0c5k.xn--p1ai"=>{:free=>0, :disposable=>1}}}

# check an email for status while summing up scores for each step in domain
lib.check 'c.nut.emailfake.nut.cc', summarize: true
# => {:provided=>"c.nut.emailfake.nut.cc",
#     :summarize=>true,
#     :total=>4,
#     :success=>true,
#     :unicode=>"c.nut.emailfake.nut.cc",
#     :reason=>:found,
#     :free=>2,
#     :disposable=>10,
#     :extra=>{
#       "c.nut.emailfake.nut.cc"=>{:free=>1, :disposable=>1},
#       "emailfake.nut.cc"=>{:free=>0, :disposable=>3},
#       "nut.cc"=>{:free=>1, :disposable=>6}}}

# check a domain for status
lib.check 'gmail.com'
# => {:provided=>"gmail.com", :summarize=>false, :total=>1, :success=>true, :unicode=>"gmail.com",
#     :reason=>:found, :free=>8, :disposable=>0, :extra=>{"gmail.com"=>{:free=>8, :disposable=>0}}}

lib.check 'nick@codewithsense.com'
# => {:provided=>"codewithsense.com", :summarize=>false, :total=>1, :success=>false,
#     :unicode=>"codewithsense.com", :reason=>:not_found}
```

In the above examples, `free` is the number of sources claiming that the given
domain/email is from a free email provider, `disposable` is the number of sources
claiming that the given domain/email is from a disposable email provider.

`total` is the number of domain parts checked for this email/domain for entries
present with us. For example, for domain `subsub.sub.root.co.in`, we check the following
strings in our records (giving us a total of 3):

- subsub.sub.root.co.in
- sub.root.co.in
- root.co.in

```plain
is = category | when count of other category is zero
maybe = category | when percent count (category) > percent count (other category) + 20
```

If `summarize` is `true`, counts for each domain parts are added starting from root domain.

The above uses pre-configured list of sources. To use your own list of
sources, provide a file with one (url) line per source.

We check the lists for inclusion of `gmail.com` and `mailinator.com` domains to
decide what kind of emails they list. To improve confidence, provide sources that
list EITHER free OR disposable emails, and not both.

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
