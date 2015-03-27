require 'spec_helper'
require 'flirt/flirt_test_classes'

describe Flirt::Listener do
    before(:each) do
        Flirt.enable
    end

    describe "when included in an instance" do
        let(:event)               { :grabbed_coin }
        let(:callback_name)       { :increase_score }
        let(:event_data)          { { value: 100 } }
        let(:instance_subscriber) { TestInstanceSubscriber.new event, callback_name }
        let(:instance_listener)   { TestInstanceListener.new event, callback_name }

        it "subscribes to an event" do
            expect(instance_subscriber).to receive(callback_name).with(event_data)
            Flirt.broadcast event, event_data
        end

        it "listens to an event" do
            expect(instance_listener).to receive(callback_name).with(event_data)
            Flirt.broadcast event, event_data
        end
    end

    describe "when included in a class" do
        let(:event)               { :event_name }
        let(:callback_name)       { :callback_name }
        let(:event_data)          { { value: 100 } }
        let(:class_subscriber)    { TestClassSubscriber }
        let(:class_listener)      { TestClassListener }

        # Because rspec has to clear the Flirt callbacks for each test,
        # we need to require the test classes after rspec init.

        it "subscribes to an event" do
            require 'flirt/test_class_subscriber'
            expect(class_subscriber).to receive(callback_name).with(event_data)
            Flirt.broadcast event, event_data
        end

        it "listens to an event" do
            require 'flirt/test_class_listener'
            expect(class_listener).to receive(callback_name).with(event_data)
            Flirt.broadcast event, event_data
        end
    end
end
