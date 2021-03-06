require 'spec_helper'
#require 'flirt/flirt_test_classes'

describe Flirt::Listener do
  before(:each) do
    Flirt.enable
  end

  describe "when included in an instance" do

    let(:event) { :grabbed_coin }

    let(:callback_name) { :increase_score }

    let(:event_data) { {value: 100} }

    let(:test_class) { Class.new }

    let(:test_instance) { test_class.new }


    before(:each) do
      test_class.class_eval do
        include Flirt::Listener
      end

    end


    it "subscribes to an event with #subscribe_to" do
      block_event = event
      block_callback_name = callback_name
      expect(Flirt).to receive(:subscribe).with(test_instance, event, {with: callback_name})
      test_instance.instance_eval do
        subscribe_to block_event, with: block_callback_name
      end

    end


    it "unsubscribes from an event with #unsubscribe_from" do
      block_event = event
      block_callback_name = callback_name
      expect(Flirt).to receive(:unsubscribe).with(test_instance, event, {with: callback_name})
      test_instance.instance_eval do
        unsubscribe_from block_event, with: block_callback_name
      end

    end

  end


  describe "when included in a class" do

    let(:event) { :event_name }

    let(:callback_name) { :callback_name }

    let(:event_data) { {value: 100} }

    let(:test_class) { Class.new }


    it "subscribes to an event with #subscribe_to" do
      block_event = event
      block_callback_name = callback_name
      expect(Flirt).to receive(:subscribe).with(test_class, event, {with: callback_name})
      test_class.class_eval do
        extend Flirt::Listener
        subscribe_to block_event, with: block_callback_name
      end

    end


    it "unsubscribes from an event with #unsubscribe_from" do
      block_event = event
      block_callback_name = callback_name
      expect(Flirt).to receive(:unsubscribe).with(test_class, event, {with: callback_name})
      test_class.class_eval do
        extend Flirt::Listener
        unsubscribe_from block_event, with: block_callback_name
      end

    end

  end

end
