require 'rake'
require 'rake/tasklib'
require 'rake/clean'
require 'lanyard'

module Rake
  class LanyardTask < Rake::TaskLib

    attr_accessor :keychain_path
    def keychain_path
      @keychain_path ? @keychain_path : "build.keychain"
    end

    attr_accessor :original_keychain_path
    def copy_keychain_from file
      @original_keychain_path = file
    end

    attr_accessor :keychain_password
    def keychain_password
      @keychain_password ? @keychain_password : ""
    end

    attr_accessor :namespace_name
    def namespace_name
      @namespace_name ? @namespace_name.to_sym : nil
    end

    def initialize keychain_path = nil, keychain_password = nil
      @keychain_path = keychain_path
      @keychain_password = keychain_password

      yield self if block_given?

      unless namespace_name.nil?
        namespace namespace_name do
          define
        end
      else
        define
      end
      self
    end

    private

    def define_unlock
      desc "unlock the build keychain"
      task :unlock => [self.keychain_path] do
        Lanyard::use_keychain self.keychain_path, self.keychain_password
        task('keychain:reset').reenable
      end
    end

    def define_reset
      desc "reset and lock the build keychain"
      task :reset => [self.keychain_path] do
        Lanyard::unuse_keychain self.keychain_path
        task('keychain:unlock').reenable
      end
    end

    def define_copy_task
      unless self.original_keychain_path.nil?
        CLEAN.include(self.keychain_path)
        desc "copies keychain from #{File.basename self.original_keychain_path}"
        file self.keychain_path do |t|
          cp self.original_keychain_path, t.name
        end
      end
    end

    def define
      define_unlock
      define_reset
      define_copy_task
    end
  end
end
