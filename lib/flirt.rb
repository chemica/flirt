require "flirt/version"
require "flirt/callback"
require "flirt/listener"
# The Flirt module provides the main interface for dealing with Flirt.
#

module Flirt

    class << self

        def broadcast(event_name, event_data)
            return if disabled
            raise ArgumentError.new("Event name must be a symbol") unless event_name.is_a? Symbol
            (callbacks[event_name] || []).each do |callback|
                callback.call(event_data)
            end
        end
        alias_method :publish, :broadcast

        def subscribe(object, event_name, options = {})
            raise ArgumentError.new("You must pass a callback")    unless options[:with].is_a? Symbol
            raise ArgumentError.new("You must pass an object")     if     object.nil?
            raise ArgumentError.new("You must pass an event name") unless event_name.is_a? Symbol
            callback = Flirt::Callback.new object: object,
                                           callback_name: options[:with]
            add_callback(event_name, callback)
        end
        alias_method :listen, :subscribe

        def enable
            self.disabled = false
        end

        def disable
            self.disabled = true
        end

        def clear
            @callbacks = {}
        end

        private

        attr_reader   :callbacks
        attr_accessor :disabled

        def callbacks
            @callbacks ||= {}
        end

        def add_callback(event_name, callback)
            callbacks[event_name] ||= []
            callbacks[event_name] << callback
        end

    end

end
