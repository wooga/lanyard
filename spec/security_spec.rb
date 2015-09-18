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

  describe 'find_generic_password' do
    it "calls find-generic-password" do
      expect(Open3).to receive(:popen3).with("security", "find-generic-password", any_args).and_return true
      subject.find_generic_password
    end

    it "calls with -g filter to show password" do
      expect(Open3).to receive(:popen3).with("security", "find-generic-password", "-g", any_args).and_return true
      subject.find_generic_password
    end

    it "calls with proviced keychains" do
      expect(Open3).to receive(:popen3).with("security", "find-generic-password", "-g", test_keychain, test_keychain).and_return true
      subject.find_generic_password test_keychain, test_keychain
    end

    let(:option_values){
      {
        account: "testAccount",
        creator: "MAEN",
        type: "TEST",
        kind: "test password",
        value: "test value",
        label: "test label",
        comment: "short comment",
        service: "testService",
      }
    }

    let(:expected_options){
      [
        "-a", option_values[:account],
        "-j", option_values[:comment],
        "-c", option_values[:creator],
        "-D", option_values[:kind],
        "-l", option_values[:label],
        "-s", option_values[:service],
        "-C", option_values[:type],
        "-G", option_values[:value],
      ]
    }

    let(:expected_password){"iZAeN7vRzQtR3UCTNwxVXrZpNLyWRhgmtrhgYLKuUoREBiWBWi"}

    let(:find_generic_password_result){
%Q(keychain: "/Users/larusso/Library/Keychains/login.keychain"
class: "genp"
attributes:
    0x00000007 <blob>="TEST"
    0x00000008 <blob>=<NULL>
    "acct"<blob>="TEST"
    "cdat"<timedate>=0x32303134313131373038323233385A00  "20141117082238Z\000"
    "crtr"<uint32>=<NULL>
    "cusi"<sint32>=<NULL>
    "desc"<blob>="Encrypted Volume Password"
    "gena"<blob>=<NULL>
    "icmt"<blob>=<NULL>
    "invi"<sint32>=<NULL>
    "mdat"<timedate>=0x32303134313131373038323233385A00  "20141117082238Z\000"
    "nega"<sint32>=<NULL>
    "prot"<blob>=<NULL>
    "scrp"<sint32>=<NULL>
    "svce"<blob>="6FFC3DA2-7447-4419-B73E-ADC9B8CC3D6F"
    "type"<uint32>=<NULL>
password: "#{expected_password}")
    }

    it "returns password" do
      allow(Open3).to receive(:popen3).with("security", "find-generic-password", "-g","-a", "TEST").and_yield("stdin", find_generic_password_result, "stderr", nil)
      expect(subject.find_generic_password(account:"TEST")).to eql expected_password
    end

    it "calls with provided filter options" do
      expect(Open3).to receive(:popen3).with("security", "find-generic-password", "-g", *expected_options)
      subject.find_generic_password(**option_values)
    end

    it "calls with provided filter options and keychains" do
      expect(Open3).to receive(:popen3).with("security", "find-generic-password", "-g", *expected_options, test_keychain, test_keychain)
      subject.find_generic_password(test_keychain, test_keychain, **option_values)
    end
  end

end
