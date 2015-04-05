require "flirt/version"
require "flirt/callback"
require "flirt/listener"

# The Flirt module provides the main interface for dealing with Flirt. Callbacks can be registered or unregistered
# against events, and Flirt can be enabled or disabled.

module Flirt

    class << self

        def publish(event_name, event_data)
            return if disabled
            return if disabled_list && disabled_list.include?(event_name)
            return if enabled_list && !enabled_list.include?(event_name)
            raise ArgumentError.new("Event name must be a symbol") unless event_name.is_a? Symbol

            (callbacks[event_name] || []).each do |callback|
                callback.call(event_data)
            end
        end


        def subscribe(object, event_name, options = {})
            check_subscription_arguments(event_name, object, options)
            callback = Flirt::Callback.new object:        object,
                                           callback_name: options[:with],
                                           weakref:       options[:weakref]
            add_callback(event_name, callback)
        end


        def unsubscribe(object, event_name, options = {})
            check_subscription_arguments(event_name, object, options)
            callback = Flirt::Callback.new object: object,
                                           callback_name: options[:with]
            remove_callback(event_name, callback)
        end


        def enable(opts = {})
            clear_event_lists
            if opts[:only]
                set_enabled opts[:only]
            end
            self.disabled = false
        end


        def disable(opts = {})
            clear_event_lists
            if opts[:only]
                set_disabled opts[:only]
                self.disabled = false
            else
                self.disabled = true
            end
        end


        def clear
            @callbacks = {}
        end


        private

        attr_reader   :callbacks
        attr_accessor :disabled, :disabled_list, :enabled_list


        def callbacks
            @callbacks ||= {}
        end


        def add_callback(event_name, callback)
            callbacks[event_name] ||= []
            callbacks[event_name] << callback
        end


        def set_disabled(events)
            self.disabled_list = wrap_event_list(events)
        end


        def set_enabled(events)
            self.enabled_list = wrap_event_list(events)
        end


        def clear_event_lists
            self.enabled_list  = nil
            self.disabled_list = nil
        end


        def wrap_event_list(events)
            events.is_a?(Array) ? events : [events]
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
