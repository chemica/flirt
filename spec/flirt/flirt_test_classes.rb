
class TestSubscriber

    attr_accessor :responded

    def initialize(event)
        Flirt.subscribe self, event, with: :respond
    end

    def respond(event_data)
        self.responded = event_data
    end
end


class TestListener

    attr_accessor :responded

    def initialize(event)
        Flirt.listen self, event, with: :respond
    end

    def respond(event_data)
        self.responded = event_data
    end
end

class TestInstanceSubscriber
    include Flirt::Listener

    def initialize(event, callback)
        subscribe_to event, with: callback
    end
end

class TestInstanceListener
    include Flirt::Listener

    attr_accessor :responded

    def initialize(event, callback)
        listen_to event, with: callback
    end
end