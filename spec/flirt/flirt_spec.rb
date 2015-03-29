require 'spec_helper'
#require 'flirt/flirt_test_classes'

describe Flirt do

    describe "with a single :pancake_fried subscriber" do

        let(:response)    { { topping: "cream" } }
        let(:event)       { :pancake_fried }
        let(:wrong_event) { :spud_baked }
        let(:callback)    { :respond }
        let!(:listener)   { Object.new }

        before(:each) do
            block_event = event
            block_callback = callback
            listener.instance_eval { Flirt.listen self, block_event, with: block_callback }
        end

        it "listens to the correct broadcast event" do
            expect(listener).to receive(callback).with(response)
            Flirt.broadcast event, response
        end

        it "listens to the correct publish event" do
            expect(listener).to receive(callback).with(response)
            Flirt.publish event, response
        end

        it "doesn't listen to the wrong broadcast event" do
            expect(listener).not_to receive(callback).with(response)
            Flirt.broadcast wrong_event, response
        end

        it "doesn't listen to the wrong publish event" do
            expect(listener).not_to receive(callback).with(response)
            Flirt.broadcast wrong_event, response
        end
    end
end