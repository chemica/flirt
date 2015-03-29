require 'spec_helper'

describe Flirt::Callback do
    before(:each) do
        Flirt.enable
    end

    describe "when instantiated with an object and callback name" do

        let(:listener) { Object.new }
        let(:callback_name) { :call_me }

        let(:callback) { Flirt::Callback.new object: listener, callback_name: callback_name }

        it "sets the object" do
            expect(callback.object).to eq(listener)
        end

        it "sets the callback" do
            expect(callback.callback_name).to eq(callback_name)
        end

        describe "when called" do

            let(:event_data) { {event: :data} }

            it "calls the callback with the event data" do
                expect(listener).to receive(callback_name).with(event_data)
                callback.call(event_data)
            end
        end

        it "tests equality if object and callback are the same" do
            other_callback = Flirt::Callback.new object: listener, callback_name: callback_name
            expect(callback).to eq(other_callback)
        end
    end
end