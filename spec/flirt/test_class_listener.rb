class TestClassListener
    extend Flirt::Listener

    class << self
        attr_accessor :responded
    end

    listen_to :event_name, with: :callback_name
end