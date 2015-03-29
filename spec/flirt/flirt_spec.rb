require 'spec_helper'
#require 'flirt/flirt_test_classes'

describe Flirt do

    describe "with a single :pancake_fried subscriber" do

        let(:response)    { { topping: "cream" } }

        let(:event)       { :pancake_fried }

        let(:wrong_event) { :spud_baked }

        let(:callback)    { :respond }

        let!(:listener)   { Object.new }


        [:subscribe, :listen].each do |method|

            describe "and a listener added with ##{method}" do

                before(:each) do
                    Flirt.send method, listener, event, with: callback
                end


                [:publish, :broadcast].each do |method|

                    it "listens to the correct event published with ##{method}" do
                        expect(listener).to receive(callback).with(response)
                        Flirt.send method, event, response
                    end


                    it "doesn't listen to the wrong event published with ##{method}" do
                        expect(listener).not_to receive(callback)
                        Flirt.send method, wrong_event, response
                    end


                    describe "when disabled" do

                        before(:each) { Flirt.disable }

                        after(:each) { Flirt.enable }


                        it "doesn't broadcast an event published with ##{method}" do
                            expect(listener).not_to receive(callback)
                            Flirt.send method, event, response
                        end

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

                [:unsubscribe, :unlisten].each do |method|

                    describe "when another listener is added and the original unsubscribed with ##{method}" do

                        let(:callback2)    { :respond2 }


                        before(:each) do
                            Flirt.listen listener, event, with: callback2
                            Flirt.send method, listener, event, with: callback
                        end


                        it "it forgets the original listener but remembers the new one" do
                            expect(listener).not_to receive(callback)
                            expect(listener).to receive(callback2).with(response)
                            Flirt.broadcast event, response
                        end

                    end

                end

            end

        end

    end

end