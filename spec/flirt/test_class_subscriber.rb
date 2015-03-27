class TestClassSubscriber
    extend Flirt::Listener

    class << self
        attr_accessor :responded
    end

    subscribe_to :event_name, with: :callback_name
end
