module Gitdeploy
  class GlobalConfig < Hash
    def initialize(options)
      self[:auth] = (options['auth'] || {}).hmap do |k, v|
        [k, v.symbolize_keys]
      end
      self[:gitlab] = (options['gitlab'] || {}).hmap do |k, v|
        [k, v.symbolize_keys]
      end
    end

    def auth(options)
      host = ''
      host += "#{options[:user]}@" if options[:user]
      host += "#{options[:host]}"

      self[:auth][host]
    end

    def gitlab(key)
      self[:gitlab][key]
    end
  end
end
