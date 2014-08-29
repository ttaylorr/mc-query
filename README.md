# mc-query

MCQuery is a Rubygem that includes ruby bindings to the Minecraft RCON protocol.

## Installation

Add this line to your application's Gemfile:

    gem 'mc_query'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mc_query

## Usage

Using `mc_query` is really simple.  Simply stick `require mc_query` at the top of your Ruby file, and then make a query.  Here, I will query the [Overcast Network](http://oc.tc).

```ruby
require 'mc_query'

mc = MCQuery.new({:ip => 'us.oc.tc'})
mc.simple_query

# => {
#      :name => "My Server",
#      :gametype => "SMP",
#      :world_name => "world",
#      :online_players => "0",
#      :max_players => "150",
#      :ip => "10.0.0.1",
#    }
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/mc_query/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
