# Syntactic sugar for adding a listener. Use include or extend to
# add listen/subscribe behaviour to your class instance
# or class body.

# class MyListener
#     include Flirt::Listener
#
#     def initialize
#         subscribe_to :picked, with: :picked_callback
#         # or the alias
#         listen_to :picked, with: :picked_callback
#     end
#
#     def picked_callback(event_data)
#         puts "The #{event_data[:fruit]} has been picked"
#     end
# end
#
# or:
#
# class MyListener
#     extend Flirt::Listener
#
#     subscribe_to :picked, with: :picked_callback
#     # or the alias
#     listen_to :picked, with: :picked_callback
#
#     def self.picked_callback(event_data)
#         puts "The #{event_data[:fruit]} has been picked"
#     end
# end
#

module Flirt

    module Listener

        def subscribe_to(event_name, opts = {})
            Flirt.subscribe self, event_name, opts
        end


        def unsubscribe_from(event_name, opts = {})
            Flirt.unsubscribe self, event_name, opts
        end

    end

end