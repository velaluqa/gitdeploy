module Gitdeploy
  class SimpleDeployment < Deployment
    attr_accessor :exclude, :delete

    def initialize(options = {})
      super(options)

      @exclude = options[:exclude]
      @delete  = options[:delete]

      @steps = [:ensure_dest_dir, :deploy_files]
    end

    def ensure_dest_dir
      Dir.ensure(destination)
    end

    def deploy_files
      puts "Deploying to #{destination.path} on #{destination.host} ..."

      options = {}
      (options[:options] ||= {})[:exclude] = exclude if exclude
      (options[:flags] ||= []) << :e if delete

      Dir.sync(sources, destination, options)
    end
  end
end
