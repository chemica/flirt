require 'spec_helper'
require 'flirt/flirt_test_classes'

describe "Flirt integration" do
    before(:each) do
        Flirt.enable
    end

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


# A single point where events can be broadcast to and listeners can be registered.
#
# To publish:
#     event_data = { fruit: "apple" }
#     Flirt.broadcast :fruit_picked, event_data
# Or:
#     Flirt.publish :fruit_picked, event_data
# (These are aliases of each other)
#
# To subscribe:
#
# class MyListener
#     def initialize
#         Flirt.subscribe self, :fruit_picked, with: :fruit_picked_callback
#         # or the alias
#         Flirt.listen self, :fruit_picked, with: :fruit_picked_callback
#     end
#
#     def fruit_picked_callback(event_data)
#         puts "The #{event_data[:fruit]} has been picked"
#     end
# end
#
# Syntactic sugar for subscription has been provided in the form of a module:
#
# class MyListener
#     include FlirtListener
#
#     def initialize
#         subscribe_to :fruit_picked, with: :fruit_picked_callback
#         # or the alias
#         listen_to :fruit_picked, with: :fruit_picked_callback
#     end
#
#     def fruit_picked_callback(event_data)
#         puts "The #{event_data[:fruit]} has been picked"
#     end
# end
#
# or even:
#
# class MyListener
#     extend Flirt::Listener
#
#     subscribe_to :fruit_picked, with: :fruit_picked_callback
#     # or the alias
#     listen_to :fruit_picked, with: :fruit_picked_callback
#
#     def self.fruit_picked_callback(event_data)
#         puts "The #{event_data[:fruit]} has been picked"
#     end
# end
