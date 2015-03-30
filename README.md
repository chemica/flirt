# Flirt

This Ruby gem is a brutally simple take on the observer pattern.

Flirt acts as a single point to which events can be sent and listeners 
can be registered, in order to promote extreme decoupling between components.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flirt'
```

And then execute:

```ruby
$ bundle
```

Or install it yourself as:

```ruby
    $ gem install flirt
```


## Usage

To publish an event:


```ruby
Flirt.publish :picked, event_data
```

To subscribe:

```ruby
class MyListener
    def initialize
        Flirt.subscribe self, :picked, with: :picked_callback
    end

    def picked_callback(event_data)
        puts "The #{event_data[:fruit]} has been picked"
    end
end
```

To unsubscribe:

```ruby
    Flirt.unsubscribe self, :picked, with: :picked_callback
end
```


Syntactic sugar for subscription and unsubscription has been provided in the form of a module:

```ruby
class MyListener
    include Flirt::Listener

    def initialize
        subscribe_to :picked, with: :picked_callback
    end
    
    def before_destroy
        unsubscribe_from :picked, with: :picked_callback
    end

    def picked_callback(event_data)
        puts "The #{event_data[:fruit]} has been picked"
    end
end
```

or even:

```ruby
class MyListener
    extend Flirt::Listener

    subscribe_to :picked, with: :picked_callback

    def self.picked_callback(event_data)
        puts "The #{event_data[:fruit]} has been picked"
    end
end
```

```unsubscribe_from``` can technically be used in the class context, but probably doesn't have as much use.

Flirt defaults to 'enabled'. Switch Flirt off:

```ruby
Flirt.disable
```

And back on again:

```ruby
Flirt.enable
```

TODO: Disable only a set of events:

```ruby
Flirt.disable only: [:pancake_cooked, :picked]
```

TODO: Enable only a set of events:

```ruby
Flirt.enable only: [:topping_added, :pancake_flipped]
```

Enabled status affects broadcast/publish, listeners can still be added and will be
remembered. No listeners will be removed.

Clear all listeners:

```ruby
Flirt.clear
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/flirt/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
