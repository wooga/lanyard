require 'lanyard'

module Lanyard
  def self.convert_options options
    Hash[options.select{|key, value|
      key.to_s.start_with? '--'
    }.collect{|key, value|
      [key.to_s.gsub("--","").gsub("-","_").to_sym, value]
    }]
  end

  def self.execute options
    if options['use-keychain']
      use_keychain options['<keychain>'], options['<password>'], convert_options(options)
    elsif options['unuse-keychain']
      unuse_keychain options['<keychain>'], convert_options(options)
    end
  end
end
