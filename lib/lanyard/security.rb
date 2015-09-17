require 'set'
require 'open3'

module Lanyard
  class Security

    attr_accessor :keychains

    def keychains
      keychains = []
      Open3::popen3("security list-keychain -d user") do | stdin, stdout, stderr, wait_thr |
        stdout.each_line { |line|
          keychains << line.gsub(/["\s+]/, "")
        }
      end

      keychains
    end

    def keychains= keychains
      abort "can`t append keychain[s]." unless system "security", "list-keychain", "-d", "user", "-s", *keychains.uniq
    end

    def unlock_keychain keychain, password
      abort "can't unlock keychain #{keychain}" unless system "security", "unlock-keychain", "-p", password, keychain
    end

    def lock_keychain keychain
      abort "can't lock keychain #{keychain}" unless system "security", "lock-keychain", keychain
    end

    def set_keychain_settings keychain:nil, verbose:true, lock_sleep:false, lock_after_timeout:false, lock_timeout:7200
      args = ["security"]
      args << "-v" if verbose
      args << "set-keychain-settings"
      args << "-l" if lock_sleep
      args << "-ut #{lock_timeout}" if lock_after_timeout
      args << keychain if keychain

      abort "can't set keychain settings #{keychain}" unless system(*args)
    end

    def print_keychain_info keychain
      system "security", "show-keychain-info", keychain
    end
  end
end
