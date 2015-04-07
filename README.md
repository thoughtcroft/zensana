# Zensana

This gem provides access to the Asana API and ZenDesk Ticket Import API
for the purpose of importing tasks from Asana Projects into ZenDesk
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
by creating an API key. The following environment vars are required:

```ruby
ASANA_API_KEY
  or
ASANA_USERNAME
ASANA_PASSWORD
```

### ZenDesk

ZenDesk by default requires username / password to connect to the API,
and the endpoint is defined by the organisation domain name. The following
environment vars are required:

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

# License

### This code is free to use under the terms of the MIT license.

Copyright (c) 2015 Warren Bain

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
