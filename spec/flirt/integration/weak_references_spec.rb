require 'spec_helper'
require 'weakref'

describe Flirt do

    describe "with one strongly referenced subscriber" do

        let(:event) { :event }

        before(:each) do
            klass = Struct.new(:callback)
            inst = klass.new
            @weakref_of_strongref = WeakRef.new(inst)
            Flirt.subscribe inst, event, with: :"callback="
        end


        describe "and with one weakly referenced subscriber" do

            before(:each) do
                klass = Struct.new(:callback)
                inst = klass.new
                @weakref = WeakRef.new(inst)
                Flirt.subscribe inst, event, with: :"callback=", weakref: true
            end


            it "should not throw an exception on publish" do
                GC.start
                Flirt.publish event, :response
            end


            it "should use a weak reference when weakref option set" do
                GC.start
                expect(@weakref.weakref_alive?).not_to eq(true)
            end


            it "should not use a weak reference when weakref option not set" do
                GC.start
                expect(@weakref_of_strongref.weakref_alive?).to eq(true)
            end
        end
    end
end