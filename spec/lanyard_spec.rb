require 'spec_helper'

describe Lanyard::Lanyard do

  let(:security) {double(Lanyard::Security).as_null_object}
  let(:subject) {Lanyard::Lanyard.new security}

  let(:list_keychain_result) { %w(/path/to/local.keychain /path/to/system.keychain)}
  let(:test_keychain) {"/path/to/keychain.keychain"}
  let(:test_keychain_password) {"keychainPass"}

  before(:each) do
    allow(security).to receive(:keychains).and_return(list_keychain_result)
  end

  describe 'use_keychain' do
    it "validates keychain and password count are equal" do
      expect{subject.use_keychain [:keychain1,:keychain2], [:password]}.to raise_error(SystemExit)
    end

    context "when user has keychains in lookup list" do
      it "appends keychain to lookup list" do
        expect(security).to receive(:keychains=).with(list_keychain_result + [test_keychain])
        subject.use_keychain test_keychain, test_keychain_password
      end
    end

    context "when user has no keychains in lookup list" do

      let(:list_keychain_result) {[]}

      it "adds keychain to lookup list" do
        expect(security).to receive(:keychains=).with([test_keychain])
        subject.use_keychain test_keychain, test_keychain_password
      end
    end

    context "when unlock option is set" do
      it "unlocks keychain[s]" do
        expect(security).to receive(:unlock_keychain).with(test_keychain, test_keychain_password)
        subject.use_keychain "/path/to/keychain.keychain", "keychainPass"
      end

      it "sets keychain[s] settings" do
        expect(security).to receive(:set_keychain_settings).with({:keychain=>"/path/to/keychain.keychain",
          :lock_sleep=>true,
          :lock_after_timeout=>true,
          :lock_timeout=>7200})
        subject.use_keychain "/path/to/keychain.keychain", "keychainPass"
      end
    end

    context "when unlock option is not set" do
      it "leaves keychain[s] locked" do
        expect(security).not_to receive(:unlock_keychain).with(test_keychain, test_keychain_password)
        expect(security).not_to receive(:set_keychain_settings)
        subject.use_keychain "/path/to/keychain.keychain", "keychainPass", unlock: false
      end
    end
  end

  describe 'unuse_keychain' do
    it "locks keychain[s]" do
      expect(security).to receive(:lock_keychain).with(test_keychain)
      subject.unuse_keychain test_keychain
    end

    context "when user has keychains in lookup list" do
      it "removes keychain[s] from lookup list" do
        expect(security).to receive(:keychains=).with(list_keychain_result)
        subject.unuse_keychain test_keychain
      end
    end

    context "when user has no keychains in lookup list" do
      let(:list_keychain_result) {[]}
      it "removes keychain[s] from lookup list" do
        expect(security).to receive(:keychains=).with(list_keychain_result)
        subject.unuse_keychain test_keychain
      end
    end
  end

  describe 'lock_keychain' do
    it "locks keychains" do
      expect(security).to receive(:lock_keychain).with(test_keychain).exactly(3).times
      subject.lock_keychain [test_keychain,test_keychain,test_keychain]
    end

    it "locks keychain" do
      expect(security).to receive(:lock_keychain).with(test_keychain)
      subject.lock_keychain test_keychain
    end

  end

  describe 'module functions' do
    let(:subject){ Lanyard }

    let(:lanyard_instance) {
      inst = double(Lanyard::Lanyard)
      allow(Lanyard::Lanyard).to receive(:new).and_return inst
      inst
    }

    context "use_keychain" do
      it "invokes method in class instance" do
        expect(lanyard_instance).to receive(:use_keychain).with(test_keychain, test_keychain_password, test:true)
        subject.use_keychain test_keychain, test_keychain_password, test:true
      end
    end

    context "lock_keychain" do
      it "invokes method in class instance" do
        expect(lanyard_instance).to receive(:lock_keychain).with(test_keychain, test:true)
        subject.lock_keychain test_keychain, test:true
      end
    end

    context "unuse_keychain" do
      it "invokes method in class instance" do
        expect(lanyard_instance).to receive(:unuse_keychain).with(test_keychain, test:true)
        subject.unuse_keychain test_keychain, test:true
      end
    end
  end
end
