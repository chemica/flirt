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
            Flirt.listen listener, event, with: callback
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
            expect(listener).not_to receive(callback)
            Flirt.broadcast wrong_event, response
        end

        it "doesn't listen to the wrong publish event" do
            expect(listener).not_to receive(callback)
            Flirt.broadcast wrong_event, response
        end

        describe "when disabled" do
            before(:each) { Flirt.disable }
            after(:each) { Flirt.enable }

            it "doesn't broadcast" do
                expect(listener).not_to receive(callback)
                Flirt.broadcast event, response
            end

            it "doesn't publish" do
                expect(listener).not_to receive(callback)
                Flirt.publish event, response
            end
        end

        describe "when cleared" do

            let(:callback2)    { :respond2 }

            before(:each) do
                Flirt.listen listener, event, with: callback2
                Flirt.clear
            end

            it "forgets listeners" do
                expect(listener).not_to receive(callback)
                expect(listener).not_to receive(callback2)
                Flirt.publish event, response
            end

        end

        describe "when unlistened" do

            let(:callback2)    { :respond2 }

            before(:each) do
                Flirt.listen listener, event, with: callback2
                Flirt.unlisten listener, event, with: callback
            end

            it "forgets the listener" do
                expect(listener).not_to receive(callback)
                expect(listener).to receive(callback2).with(response)
                Flirt.broadcast event, response
            end

        end

        describe "when unsubscribed" do
            before(:each) do
                Flirt.unsubscribe listener, event, with: callback
            end

            it "forgets the listener" do
                expect(listener).not_to receive(callback).with(response)
                Flirt.publish event, response
            end

        end
    end
end