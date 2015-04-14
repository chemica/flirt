# Flirt

A brutally simple take on the observer pattern.

Flirt acts as a single point to which events can be sent (published) and listeners 
can be registered (subscribed), in order to promote extreme decoupling between components.


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
Flirt.enable only: [:flipped]
```

The above code will leave only ```:flipped``` enabled.

Calling ```Flirt.enable``` or ```Flirt.disable``` will clear any previously set enabled or disabled events.


###Clear all listeners:

```ruby
Flirt.clear
```

This operation cannot be undone. Cleared listeners would have to be re-added one by one.


##Motivation

Ruby projects (and Rails projects in particular) can easily become a mess of tightly coupled code. The Rails framework almost encourages the idea of 'fat models', with features like callbacks (often touching other models and thus coupling themselves) and concerns (that use modules to hide code that often should really have its own class) to name but two.

The observer (or pub/sub) pattern can help decouple code, decompose large classes and allow for smaller classes with a single purpose. This promotes easy testing, readability, maintainability and eventually stability of your code.

So why use Flirt?


### Flirt is tiny

Flirt gives you just enough to use and test the pub/sub pattern with the minimum of cruft. The number of objects is kept to a minimum for speed and ease of debugging. The extendable Listener module has only the two methods you need to use.


### Flirt use is obvious and readable

With such a simple syntax, it's easy to understand what Flirt is doing when you revisit your code again in three months.


### Flirt is opinionated

For basic use there is no set-up necessary beyond requiring the gem.

Events can only be represented as symbols, avoiding problems with string/symbol confusion.

Only one parameter can be passed as event data, encouraging structured data objects (hashes, structs or class instances) rather than unreadable parameter lists.

Only one object (Flirt itself) can be listened to, reducing the danger of implicit coupling between publishers and subscribers. Subscribers listen to events, not objects.


### Flirt doesn't use threads or persistence frameworks. 

This means events are fired in a deterministic way, without over-obfuscating the control flow for debug tools. You can depend on listeners being called before, for example, the end of a controler call. If you wish to delegate a task to a worker thread (like Sidekiq for example) it's easy enough to do in a listener and you're not tied to any particular implementation.


### Flirt has a great name

Seriously, why use any other pub/sub system when you could be flirting instead?


## Patterns and suggested use

#### Listener files

It can help project organisation if you keep your listeners in one place (in Rails you could use app/listeners) and minimise the logic in the listener class itself. Delegate to service objects when possible:

```ruby
class MyListener
  extend Flirt::Listener

  subscribe_to :cooked, with: :cooked_callback

  def self.cooked_callback(pancake)
    ToppingAdder.new(pancake).add(:blueberry)    
  end
end
```

This will make finding your listeners very easy. It also decouples the service object completely from the event process, meaning it can be used in other contexts and testing is a breeze. 

This style of coding promotes the Single Responsibility Principle: "A class should only have one reason to change." The class only requires amending if the event specification changes. 


#### Event objects

It may be useful to use an object to keep a repository of event symbols or define a class to specify an event:

```ruby
class Events
  FLIPPED = :flipped
  COOKED  = :cooked
  ...
end

...

Flirt.publish Events::COOKED, pancake
```

This eliminates invisible errors due to typos in event symbols and gives IDEs a fighting chance of giving you auto-complete for event names. This style of coding promotes DRY principles: "Every piece of knowledge must have a single, unambiguous, authoritative representation within a system."

Alternatively, an event class might look something like this but will obviously depend on the project:

```ruby
class PouredEvent
  attr_accessor :millilitres, :time
  
  def initialize(opts = {})
    self.millilitres = opts.fetch(:millilitres)
    self.time        = opts.fetch(:time)
  end
  
  def self.name; :poured; end
end

...

Flirt.publish PouredEvent.name, PouredEvent.new(millilitres: 20, time: Time.now) 

```


## Antipatterns and misuse

#### Clearing and disabling

The ```clear```, ```enable``` and ```disable``` features are provided to aid testing. If you find yourself reaching for them in production code you're probably using the wrong pattern, or you may need to re-think your architecture.

Have a look at decorators if you need to add different functionality to a model depending on where it's called.

Alternatively, change the location in the code where you publish your events. A useful move in Rails is from the model to the controller, to avoid admin or other background updates triggering events that should only be based on user actions. This kind of move can also help break some event or callback loops, where a side effect of one event causes another event to fire and vice versa. ActiveRecord save and validate callbacks (and thus events based on them) are particularly prone to this.

#### Garbage collection

If you find yourself creating and throwing away multiple listener objects, Ruby will still keep references to those objects for the lifetime of the application.  This can result in memory leaks, as Ruby will not be able to garbage collect the listeners. To avoid this situation, ensure you unsubscribe from any events when you're done with them. Alternatively, on subscription you can request that Flirt uses weak references:

```ruby
Flirt.subscribe object, :flipped, with: :flipped_callback, weakref: true 
```

This means that garbage collection can target the listener. Be careful though, as the listener will be garbage collected unless you keep a reference to it somewhere else. This kind of code would be problematic:

```ruby
def set_listener
  Flirt.subscribe TossedListener.new, :tossed, with: :tossed_callback, weakref: true
end
```

This will lead to intermittent bugs as nothing keeps a reference to ```TossedListener.new```. The listener will work until garbage collection kicks in.

Flirt defaults to using strong references to ensure consistent behaviour.


## Set-up

While no set-up is required for basic Flirt use, there is a quirk of Rails autoloading that could cause issues.

If you wish to use listeners on a class level, you must make sure the class is loaded. If the class definition has not been required, the listener will not be registered.

Rails auto-loads classes when they're first referenced so unless you take an extra step, class-level listeners won't ever be loaded.

Placing the following code in an initializer will ensure that anything you place in the ```#{Rails.root}/app/listeners``` directory will get loaded when the Rails framework boots up:

```ruby
# /config/initializers/flirt.rb
Dir["#{Rails.root}/app/listeners/**/*.rb"].each {|file| require file }
```

##Testing

In order to test units of behaviour, you probably want to disable Flirt and test each unit of your code in isolation. You can always enable Flirt or individual events in your test file for integration tests.

If you're creating listeners on the fly (useful for visual applications like games and dialogue based utilities), you'll want to clear Flirt before each test to stop callbacks building up. If you're setting listeners up once (by using listeners on the class level for example, useful for applications like REST APIs and web back-ends like Rails), then you don't want to clear them for each test.

If you want to use both types of listener at once, testing may be more complex. You may want to re-think your architecture, but you could set up listeners thus:

```ruby
class FlipListener
  extend Flirt::Listener
  
  def self.subscribe
    subscribe_to Events::FLIPPED, with: :flip
  end
  subscribe
  
  def self.flip(pancake)
    PancakeFlipper.new(pancake).flip
  end
end
```

Clear Flirt for each test, then switch on individual listeners in the appropriate tests using the listener's equivalent of:

```ruby
FlipListener.subscribe
```

#### RSpec

If you're using RSpec, you probably want to disable and clear Flirt in the before block in ```spec/spec_helper.rb```:

```ruby

RSpec.configure do |config|

  config.before(:each) do
    Flirt.disable
    # Flirt.clear # unless you're using solely class-based listeners.
  end
  ...
```

#### Minitest

If you're using MiniTest, adding this to your initialisation code will disable or clear Flirt before each test:

```ruby
module FlirtMinitestPlugin
  def before_setup
    super
    Flirt.disable
    # Flirt.clear # unless you're using solely class-based listeners.
  end
end

class MiniTest::Unit::TestCase
  include FlirtMinitestPlugin
end
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/flirt/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
