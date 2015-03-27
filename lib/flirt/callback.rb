# Represents a single callback. Contains knowledge of the callback name and object
# and contains a method for calling the callback.

module Flirt
    class Callback
        attr_accessor :object, :callback_name
        def initialize(opts = {})
            self.callback_name = opts.fetch(:callback_name)
            self.object        = opts.fetch(:object)
        end

        def call(event_data)
            object.send callback_name, event_data
        end
    end
end