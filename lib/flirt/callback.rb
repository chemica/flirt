require 'weakref'

# Represents a single callback. Contains knowledge of the callback name and object
# and contains a method for calling the callback.

module Flirt

  class Callback

    attr_accessor :object, :callback_name, :callback_object_id, :weakref

    def initialize(opts = {})
      self.callback_name = opts.fetch(:callback_name)
      callback_object = opts.fetch(:object)
      self.weakref = !!opts[:weakref]
      self.object = weakref ? WeakRef.new(callback_object) : callback_object
      self.callback_object_id = callback_object.object_id
    end


    def call(event_data)
      return unless alive?
      object.send callback_name, event_data
    end


    def alive?
      return true unless weakref
      object.weakref_alive?
    end


    def ==(other_callback)
      callback_object_id == other_callback.callback_object_id &&
        callback_name == other_callback.callback_name
    end

  end
end