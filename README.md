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

###To publish an event:


```ruby
event_data = { fruit: 'apple' }
Flirt.publish :picked, event_data
```

###To subscribe:

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

###To unsubscribe:

```ruby
    Flirt.unsubscribe self, :picked, with: :picked_callback
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

###Flirt defaults to 'enabled'. Switch Flirt off:

```ruby
Flirt.disable
```

And back on again:

```ruby
Flirt.enable
```

Enabled status affects publishing only, listeners can still be added and will be
remembered. No listeners will be removed.

###Disable only a set of events:

```ruby
Flirt.disable only: [:pancake_cooked, :picked]
```

###Enable only a set of events:

```ruby
Flirt.enable only: [:topping_added, :pancake_flipped]
```

Disabling and enabling sets of events is not cumulative. The new set of events will overwrite all previous calls.
For example:

```ruby
Flirt.disable only: [:pancake_cooked, :picked]
Flirt.disable only: [:flipped]
```

The above code will leave only ```:flipped``` disabled.

```ruby
Flirt.enable only: [:flipped, :picked]
Flirt.disable only: [:flipped]
```

The above code will also leave only ```:flipped``` disabled.

Calling ```Flirt.enable``` or ```Flirt.disable``` will clear any previously set enabled or disabled events.

###Clear all listeners:

```ruby
Flirt.clear
```

This operation cannot be undone.

##Motivation

Ruby projects (and Rails projects in particular) can easily become a mess of tightly coupled code. The Rails framework almost encourages the idea of 'fat models', with features like callbacks (often touching other models and thus coupling themselves) and concerns (that use modules to hide code that often should really have its own class) to name but two.

The observer (or pub/sub) pattern can help decouple code, decompose large classes and allow for smaller classes with a single purpose. This promotes easy testing, readability, maintainability and eventually stability of your code.

So why another gem, considering there are already several gems and a Ruby language feature that implement this pattern?

### Flirt is tiny

Flirt gives you just enough to use and test the pub/sub pattern with the minimum of cruft. The number of objects is kept to a minimum for speed and ease of debugging. The extendable Listener module has only the two methods you need to use.

### Flirt use is obvious and readable

With such a simple syntax, it's easy to understand what Flirt is doing when you revisit your code again in three months.

### Flirt is opinionated

There is no set-up beyond requiring the gem.

Events are canonly be represented as symbols, helping to spot and squash certain kinds of bugs early.

Only one object - Flirt - can be listened to, reducing the danger of implicit coupling between publishers and subscribers. Subscribers listen to events, not objects.

### Flirt doesn't use threads or persistence frameworks. 

This means events are fired in a deterministic way, without over-obfuscating the control flow for debug tools. You can depend on listeners being called before, for example, the end of a controler call. If you wish to delegate a task to a worker task (like Sidekiq for example) it's easy enough to do in a listener.

### Flirt has a great name

Seriously, why use any other gem when you could be flirting instead?

## Antipatterns amd misuse

The ```clear```, ```enable``` and ```disable``` features are provided to aid testing. If you find yourself reaching for them in production code you're probably using the wrong pattern, or you may need to re-think your architecture.

Have a look at decorators if you need to add different functionality to a model depending on where it's called.

Alternatively, change the location in the code where you publish your events. A useful move in Rails is from the model to the controller, to avoid admin or other background updates triggering events that should only be based on user actions. This move can also help break some event loops, where a side effect of one event causes another event to fire and vice versa.

If you find yourself creating and destroying multiple listener objects, ensure you unsubscribe from any events when you're done with them. If you don't, Ruby will keep references to the objects for the lifetime of the application. This will most likely result in memory leaks.

## Set-up

While no set-up is required for Flirt use, there is a quirk of Rails autoloading that could cause issues.

If you wish to use listeners on a class level, you must make sure the class is loaded. If the class definition has not been required, the listener will not be registered.

Rails auto-loads classes when they're first referenced so unless you take an extra step, class-level listeners won't ever be loaded.

Placing the following code in an initializer will ensure that anything you place in the ```#{Rails.root}/app/listeners``` directory will get loaded when the Rails framework boots up:

```ruby
# /config/initializers/flirt.rb
Dir["#{Rails.root}/app/listeners/**/*.rb"].each {|file| require file }
```

##Testing

In order to test units of behaviour, you probably want to disable Flirt and test each unit of your code in isolation. You can always enable Flirt or individual events in your test file for integration tests.

You'll want to clear Flirt before each test as well, to stop callbacks building up.

If you're using RSpec, you probably want to disable and clear Flirt in the before block in ```spec/spec_helper.rb```:

```ruby

RSpec.configure do |config|

  config.before(:each) do
    Flirt.disable
    Flirt.clear
  end
  ...
```

If you're using MiniTest, something like this might help:


```ruby
module FlirtMinitestPlugin
  def before_setup
    super
    Flirt.disable
    Flirt.clear
  end
end

class MiniTest::Unit::TestCase
  include FlirtMinitestPlugin
end
```

Another gem will probably appear soon to wrap common testing patterns around the use of Flirt. Watch this space.


## Contributing

1. Fork it ( https://github.com/[my-github-username]/flirt/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
