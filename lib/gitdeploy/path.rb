require 'andand'
require 'English'

module Gitdeploy
  class Path < Struct.new(:protocol, :user, :password, :host, :port, :path)
    PARSING_REGEXP = %r{^
      ((?<protocol>[^:]+)://)?
      ((?<user>[^@:/]+)(:(?<password>[^@]+))?@)?
      ((?<host>[^@:]+)(:(?<port>\d+))?:)?
      (?<path>.+)$
    }x
    FORMATTING_REGEXP = /\[(?<inflect>[^\[\]]*?(?<var>\$\w+)[^\[\]]*?)\]/i

    def initialize(obj)
      options = parse_options(obj)

      self.protocol = options[:protocol]
      self.user     = options[:user]
      self.password = options[:password]
      self.host     = options[:host]
      self.port     = options[:port]
      self.path     = options[:path]
    end

    def global_defaults(options)
      (Gitdeploy.global.auth(options) || {}).merge(options)
    end

    def parse_options(obj)
      options = obj.is_a?(String) ? parse_path(obj) : parse_path(obj[:path])
      options.merge! obj.without(:path) if obj.is_a?(Hash)
      options = global_defaults(options)

      if options[:host]
        options[:protocol] ||= 'ssh'
      else
        options[:path] = ::File.expand_path(options[:path])
      end
      options[:port]       = options[:port].andand.to_i
      options
    end

    # Parses :protocol, :user, :password, :host, :port and :path from
    # a given string.
    def parse_path(path)
      match = PARSING_REGEXP.match(path)
      Hash[match.names.map(&:to_sym).zip(match.captures)].compact
    end

    def join(*args)
      res = clone
      args.unshift(path)
      res.path = ::File.join(*args)
      res
    end

    def [](format)
      format = format.clone
      while FORMATTING_REGEXP.match(format)
        format.gsub!(FORMATTING_REGEXP) do
          inflect = $LAST_MATCH_INFO[:inflect].to_s
          var     = $LAST_MATCH_INFO[:var].to_s
          val     = send(var[1..-1].to_sym)
          val ? inflect.gsub(var, val.to_s) : ''
        end
      end
      format
    end

    def full_host
      host ? self['[$user@][$host]'] : nil
    end

    def full
      self['[$protocol://][$user[:$password]@][$host:[$port:]][$path]']
    end

    def to_s
      self['[$host:][$path]']
    end
  end
end
