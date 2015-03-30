require "flirt/version"
require "flirt/callback"
require "flirt/listener"

# The Flirt module provides the main interface for dealing with Flirt. Callbacks can be registered or unregistered
# against events, and Flirt can be enabled or disabled.

module Flirt

    class << self

        def publish(event_name, event_data)
            return if disabled
            raise ArgumentError.new("Event name must be a symbol") unless event_name.is_a? Symbol
            (callbacks[event_name] || []).each do |callback|
                callback.call(event_data)
            end
        end


        def subscribe(object, event_name, options = {})
            check_subscription_arguments(event_name, object, options)
            callback = Flirt::Callback.new object: object,
                                           callback_name: options[:with]
            add_callback(event_name, callback)
        end


        def unsubscribe(object, event_name, options = {})
            check_subscription_arguments(event_name, object, options)
            callback = Flirt::Callback.new object: object,
                                           callback_name: options[:with]
            remove_callback(event_name, callback)
        end


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


        def remove_callback(event_name, callback_to_delete)
            return unless callbacks[event_name]

            callbacks[event_name].each do |callback|
                callbacks[event_name].delete(callback) if callback == callback_to_delete
            end
        end


        def check_subscription_arguments(event_name, object, options)
            raise ArgumentError.new("You must pass a callback")    unless options[:with].is_a? Symbol
            raise ArgumentError.new("You must pass an event name") unless event_name.is_a? Symbol
            raise ArgumentError.new("You must pass an object")     if     object.nil?
        end

    end

end
