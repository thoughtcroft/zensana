# Zensana

This gem provides access to the Asana API and ZenDesk Ticket Import API
for the purpose of importing tasks from Asana Projects into ZenDesk
tickets.

[![Gem Version](https://badge.fury.io/rb/zensana.svg)](http://badge.fury.io/rb/zensana)

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

I had a specific use-case in developing this: to get off Asana as a
support ticketing system and onto ZenDesk. So there aren't many tests
(I know, I know) and there are only a few commands available in the cli.

### CLI

This uses Thor so follows the general pattern of

    $ zensana COMMAND SUBCOMMAND OPTIONS

The help is pretty self-explanatory around the options so just try that

    $ zensana help
      Commands:
        zensana help [COMMAND]      # Describe available commands or one specific command
        zensana project SUBCOMMAND  # perform actions on Asana projects

#### project command

The primary use for zensana is to convert an Asana project's tasks into
ZenDesk tickets. The `convert` subcommand has quite a few options to
control what gets converted.

    $ zensana project help convert
      Usage:
        zensana convert PROJECT

      Options:
        -a, [--attachments], [--no-attachments]  # download and upload any attachments
                                                 # Default: true
        -c, [--completed], [--no-completed]      # include tasks that are completed
        -f, [--followers], [--no-followers]      # add task followers to ticket as cc
        -t, [--global-tags=one two three]        # array of tag(s) to be applied to every ticket imported
                                                 # Default: ["zensana"]
        -g, [--group-id=N]                       # ZenDesk group_id to assign tickets to - must not conflict with default_user
        -s, [--stories], [--no-stories]          # import stories as comments
                                                 # Default: true
        -u, [--default-user=DEFAULT_USER]        # set a default user to assign to invalid asana user items
        -v, [--verified], [--no-verified]        # `false` will send email to zendesk users created
                                                 # Default: true

      Convert PROJECT tasks to ZenDesk tickets (exact ID or NAME required)

#### idempotentcy

To ensure robustness of the conversion, especially given that internet
connection issues may interrupt it, the project conversion is idempotent
and can be restarted as many times as necessary. In particular

* tasks that have already been successfully created will not be
  recreated as tickets (the Asana task_id is stored as the Zendesk
  ticket external_id)
* attachments will only be downloaded if they do not exist in the
  download directory

### Classes

You can also directly access classes which model Asana data objects.

```ruby
require 'zensana'

my_project = Zensana::Asana::Project.new('My awesome Asana Project')

my_project.full_tasks.each do |task|
  puts "Task #{task.name} has tags: #{task.tags}"
end
```

Check ../commands/project.rb for examples in action.

#### Asana

There is support for reading:
* user
* project
* task
* attachment - downloading

#### ZenDesk

There is support for accessing and updating:
* user
* agent group (read-only)
* ticket - via the Ticket Import API only
* comment
* attachment - uploading

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

## Other Environment Vars

The default http timeout of 20 seconds can be over-ridden by supplying a
suitable value as an environment var called `ZENSANA_TIMEOUT`

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
