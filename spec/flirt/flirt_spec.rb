require 'spec_helper'
#require 'flirt/flirt_test_classes'

describe Flirt do

    describe "with a single :pancake_fried subscriber" do

        let(:response)    { { topping: "cream" } }

        let(:event)       { :pancake_fried }

        let(:wrong_event) { :spud_baked }

        let(:callback)    { :respond }

        let!(:listener)   { Object.new }


        describe "and a listener added with #subscribe" do

            before(:each) do
                Flirt.subscribe listener, event, with: callback
            end


            it "listens to the correct event published with #publish" do
                expect(listener).to receive(callback).with(response)
                Flirt.publish event, response
            end


            it "doesn't listen to the wrong event published with #publish" do
                expect(listener).not_to receive(callback)
                Flirt.publish wrong_event, response
            end


            describe "when disabled" do

                before(:each) { Flirt.disable }

                after(:each) { Flirt.enable }


                it "doesn't publish an event" do
                    expect(listener).not_to receive(callback)
                    Flirt.publish event, response
                end

            end


            describe "when cleared" do

                let(:callback2)    { :respond2 }


                before(:each) do
                    Flirt.subscribe listener, event, with: callback2
                    Flirt.clear
                end


                it "forgets listeners" do
                    expect(listener).not_to receive(callback)
                    expect(listener).not_to receive(callback2)
                    Flirt.publish event, response
                end

            end


            describe "when another listener is added and the original is unsubscribed" do

                let(:callback2)    { :respond2 }


                before(:each) do
                    Flirt.subscribe listener, event, with: callback2
                    Flirt.unsubscribe listener, event, with: callback
                end


                it "it forgets the original listener but remembers the new one" do
                    expect(listener).not_to receive(callback)
                    expect(listener).to receive(callback2).with(response)
                    Flirt.publish event, response
                end

            end

        end

    end

end