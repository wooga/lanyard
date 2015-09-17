require 'spec_helper'

describe Lanyard::Security do

  let(:test_keychain) {"/path/to/keychain.keychain"}
  let(:test_keychain_password) {"keychainPass"}
  let(:current_keychains) {[]}
  let(:list_keychain_result) {
    current_keychains.map{|path| "\t#{path}\n"}.join
  }

  describe 'keychains' do

    before(:each) do
      allow(Open3).to receive(:popen3).with("security list-keychain -d user").and_yield("",list_keychain_result,"",nil)
    end

    it "calls security list-keychain" do
      expect(Open3).to receive(:popen3).with("security list-keychain -d user")
      subject.keychains
    end

    it "calls security list-keychain -s to set new lookup list" do
      expect(subject).to receive(:system).with("security", "list-keychain", "-d", "user", "-s", test_keychain).and_return true
      subject.keychains= [test_keychain]
    end

    context 'with keychain in lookup list' do
      let(:current_keychains) { %w(/path/to/local.keychain /path/to/system.keychain)}

      it "removes whitespaces from output" do
        expect(subject.keychains).to eql current_keychains
      end

      it "adds element to current list" do
        expect(subject).to receive(:system).with("security", "list-keychain", "-d", "user", "-s", *(current_keychains + [test_keychain])).and_return true
        subject.keychains += [test_keychain]
      end
    end

    it "returns a list" do
      expect(subject.keychains).to respond_to(:each)
    end

    it "aborts when call fails" do
      expect(subject).to receive(:system).and_return false
      expect{subject.keychains = [test_keychain]}.to raise_error(SystemExit)
    end
  end

  describe 'unlock_keychain' do
    it "calls security unlock-keychain" do
      expect(subject).to receive(:system).with("security","unlock-keychain","-p", test_keychain_password, test_keychain).and_return true
      subject.unlock_keychain test_keychain, test_keychain_password
    end

    it "aborts when call fails" do
      expect(subject).to receive(:system).and_return false
      expect{subject.unlock_keychain test_keychain, test_keychain_password}.to raise_error(SystemExit)
    end
  end

  describe 'set_keychain_settings' do
    it "calls security set-keychain-settings with default values" do
      expect(subject).to receive(:system).with("security", "-v", "set-keychain-settings").and_return true
      subject.set_keychain_settings
    end

    it "calls security set-keychain-settings without verbose value" do
      expect(subject).to receive(:system).with("security", "set-keychain-settings").and_return true
      subject.set_keychain_settings verbose:false
    end

    it "calls security set-keychain-settings with lock_sleep value" do
      expect(subject).to receive(:system).with("security", "-v", "set-keychain-settings", "-l").and_return true
      subject.set_keychain_settings lock_sleep:true
    end

    it "calls security set-keychain-settings with lock_after_timeout value" do
      expect(subject).to receive(:system).with("security", "-v", "set-keychain-settings", "-ut 7200").and_return true
      subject.set_keychain_settings lock_after_timeout:true
    end

    it "calls security set-keychain-settings with lock_after_timeout and time value" do
      expect(subject).to receive(:system).with("security", "-v", "set-keychain-settings", "-ut 2000").and_return true
      subject.set_keychain_settings lock_after_timeout:true, lock_timeout: 2000
    end

    it "calls security set-keychain-settings with keychain value" do
      expect(subject).to receive(:system).with("security", "-v", "set-keychain-settings", test_keychain).and_return true
      subject.set_keychain_settings keychain:test_keychain
    end

    it "aborts when call fails" do
      expect(subject).to receive(:system).and_return false
      expect{subject.set_keychain_settings}.to raise_error(SystemExit)
    end
  end

  describe 'lock_keychain' do
    it "calls lock-keychains" do
      expect(subject).to receive(:system).with("security", "lock-keychain", test_keychain).and_return true
      subject.lock_keychain test_keychain
    end
  end

  describe 'print_keychain_info' do
    it "calls show-keychain-info" do
      expect(subject).to receive(:system).with("security", "show-keychain-info", test_keychain).and_return true
      subject.print_keychain_info test_keychain
    end
  end

end
