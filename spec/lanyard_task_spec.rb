require 'spec_helper'
require 'rake/lanyard_task'
require 'rake'

describe Rake::LanyardTask do
  include Rake

  after(:each) do
    Rake::Task.clear
  end

  describe 'initialize' do
    context 'with default values' do
      let!(:subject) {Rake::LanyardTask.new}
      it "sets default keychain path" do
        expect(subject.keychain_path).to eql "build.keychain"
      end

      it "sets default keychain password" do
        expect(subject.keychain_password).to eql ""
      end

      it "set default task namespace" do
        expect(subject.namespace_name).to be nil
      end

      it "defines :unlock task" do
        expect(Rake::Task.task_defined?(:unlock)).to be true
      end

      it "defines :reset task" do
        expect(Rake::Task.task_defined?(:reset)).to be true
      end
    end

    context 'with block initialize namespace' do
      let!(:subject) {Rake::LanyardTask.new {|t|
        t.namespace_name = :test
        }
      }

      it "defines :unlock task with namespace" do
        expect(Rake::Task.task_defined?('test:unlock')).to be true
      end

      it "defines :reset task with namespace" do
        expect(Rake::Task.task_defined?('test:reset')).to be true
      end
    end

    context 'with block initialize keychain path' do
      let!(:subject) {Rake::LanyardTask.new {|t|
        t.keychain_path = "test"
        }
      }

      it "sets keychain path" do
        expect(subject.keychain_path).to eql "test"
      end
    end

    context 'with block initialize keychain password' do
      let!(:subject) {Rake::LanyardTask.new {|t|
        t.keychain_password = "test"
        }
      }

      it "sets keychain password" do
        expect(subject.keychain_password).to eql "test"
      end
    end

    context 'with block initialize original keychain' do
      let!(:subject) {Rake::LanyardTask.new {|t|
        t.copy_keychain_from "build.keychain2"
        }
      }

      it "sets original keychain path" do
        expect(subject.original_keychain_path).to eql "build.keychain2"
      end

      it "defines copy file task" do
        expect(Rake::FileTask.task_defined?(subject.keychain_path)).to be true
      end

      it "copies keychain from original location to path" do
        expect(subject).to receive(:cp).with(subject.original_keychain_path, subject.keychain_path)
        Rake::FileTask[subject.keychain_path].execute
      end
    end
  end

  describe 'task :unlock' do
    let!(:subject) {Rake::LanyardTask.new}
    it "executes Lanyard::use_keychain" do
      expect(Lanyard).to receive(:use_keychain).with("build.keychain", "")
      Rake::Task[:unlock].execute
    end
  end

  describe 'task :reset' do
    let!(:subject) {Rake::LanyardTask.new}
    it "executes Lanyard::use_keychain" do
      expect(Lanyard).to receive(:unuse_keychain).with("build.keychain")
      Rake::Task[:reset].execute
    end
  end
end
