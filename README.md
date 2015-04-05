# Zensana

This gem provides acces to the Asana API and ZenDesk Ticket Import API
for the purpose of turning Tasks from Asana Projects into ZenDesk
tickets.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zensana'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zensana

## Usage

TODO: Write usage instructions here

## Authenticating

### Asana

Asana users can connect to the API using their username / password or
by creating an API key. The following environment vars are supported:

```ruby
ASANA_API_KEY
  or
ASANA_USERNAME
ASANA_PASSWORD
```

### ZenDesk

ZenDesk by default requires username / password to connect to the API,
and the endpoint is defined by the organisation domain name. The following
environment vars must be provided to connect:

```ruby
ZENDESK_USERNAME
ZENDESK_PASSWORD
ZENDESK_DOMAIN
```

## Contributing

1. Fork it ( https://github.com/thoughtcroft/zensana/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
