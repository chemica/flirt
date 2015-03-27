require 'spec_helper'
require 'flirt/flirt_test_classes'

describe Flirt do

    describe "with a single :pancake_fried subscriber" do

        let(:response)    { { topping: "cream" } }
        let(:event)       { :pancake_fried }
        let(:wrong_event) { :spud_baked }
        let!(:listener)   { TestListener.new(event) }

        it "listens to the correct broadcast event" do
            Flirt.broadcast event, response
            expect(listener.responded).to eq(response)
        end

        it "listens to the correct publish event" do
            Flirt.publish event, response
            expect(listener.responded).to eq(response)
        end

        it "doesn't listen to the wrong broadcast event" do
            Flirt.broadcast wrong_event, response
            expect(listener.responded).to be_nil
        end

        it "doesn't listen to the wrong publish event" do
            Flirt.broadcast wrong_event, response
            expect(listener.responded).to be_nil
        end
    end
end