require 'spec_helper'

describe Lanyard do
  let(:test_keychain) {"/path/to/keychain.keychain"}
  let(:test_keychain_password) {"keychainPass"}

  let(:default_options) {
    {
      "use-keychain" => false,
      "unuse-keychain" => false,
      "--lock-timeout" => 7200,
      "<keychain>" => [test_keychain],
      "<password>" => [test_keychain_password],
    }
  }

  let(:options) {default_options}

  describe 'execute' do
    context "use-keychain command is set" do

      let(:options) {
        default_options.merge({"use-keychain" => true})
      }

      it "invokes Lanyard::use_keychain" do
        expect(Lanyard).to receive(:use_keychain).with([test_keychain],[test_keychain_password],{lock_timeout:7200})
        subject.execute options
      end
    end

    context "unuse-keychain command is set" do

      let(:options) {
        default_options.merge({"unuse-keychain" => true})
      }

      it "invokes Lanyard::unuse_keychain" do
        expect(Lanyard).to receive(:unuse_keychain).with([test_keychain],{lock_timeout:7200})
        subject.execute options
      end
    end
  end

  describe 'convert_options' do

    let(:options) {
      {
        "comannd1" => true,
        "--use-option1" => false
      }
    }

    let(:converted_options) {subject.convert_options options}

    it "removes non option values" do
      expect(converted_options.length).to eql 1
    end

    it "removes leading dashes from option" do
      expect(converted_options.keys.first.to_s).not_to start_with("--")
    end

    it "convert - to _" do
      expect(converted_options.keys.first.to_s).not_to include("-")
    end

    it "converts to symbol" do
      expect(converted_options.keys.first).to be_kind_of(Symbol)
    end
  end
end
