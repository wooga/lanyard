require "lanyard/version"
require "lanyard/security"

module Lanyard
  class Lanyard
    attr_reader :security

    def initialize security=nil
      @security = security
      unless @security
        @security = Security.new
      end
    end

    public
    def use_keychain keychain, password, **options
      keychain = [keychain] unless keychain.respond_to?('each')
      password = [password] unless password.respond_to?('each')
      abort "count of keychains and password need to be equal" if keychain.count != password.count

      security.keychains += keychain

      keychain.zip(password) do |product|
        keychain = product[0]
        password = product[1]

        if options.fetch(:unlock, true)
          security.unlock_keychain(keychain, password)
          security.set_keychain_settings( keychain:keychain,
          lock_sleep:true,
          lock_after_timeout:true,
          lock_timeout: options.fetch(:lock_timeout, 7200))
          security.print_keychain_info keychain
        end
      end
    end

    def unuse_keychain keychain, **options
      keychain = [keychain] unless keychain.respond_to?('each')

      lock_keychain keychain, **options
      security.keychains -= keychain
    end

    def lock_keychain keychain, **options
      keychain = [keychain] unless keychain.respond_to?('each')

      keychain.each {|k|
        security.lock_keychain k
      }
    end
  end

  def self.use_keychain keychain, password, **options
    lanyard = Lanyard.new
    lanyard.use_keychain keychain, password, **options
  end

  def self.lock_keychain keychain, **options
    lanyard = Lanyard.new
    lanyard.lock_keychain keychain, **options
  end

  def self.unuse_keychain keychain, **options
    lanyard = Lanyard.new
    lanyard.unuse_keychain keychain, **options
  end

end
