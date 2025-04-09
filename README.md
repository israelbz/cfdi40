# Cfdi40

Tool for read, create, validate and sign CFDIs version 4.0

CFDI (Comprobante Fiscal Digital por Internet) are XML documents
regulated by mexican goverment for tax purpouses.

Please see `README_es-MX.md`

TODO: Document, document, document

## Features

* XML generation and sign.
* Node 'iedu'
* Concept is calculated from gross price or net price

## Future features

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cfdi40'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install cfdi40

## Usage

Work in progress

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake test` to run the tests. You can also run `bin/console`
for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake
install`. To release a new version, update the version number in
`version.rb`, and then run `bundle exec rake release`, which will create
a git tag for the version, push git commits and the created tag, and
push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing

Run all test

    bundle exec rake test

Run all test in a file

    bundle exec ruby -Ilib:test test/test_cfdi40.rb

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/[USERNAME]/cfdi40. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected
to adhere to the [code of
conduct](https://github.com/israelbz/cfdi40/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Cfdi40 project's codebases, issue trackers,
chat rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/[USERNAME]/cfdi40/blob/master/CODE_OF_CONDUCT.md).
