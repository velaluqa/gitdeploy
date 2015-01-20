require 'gitdeploy/builder/build_readme'

module Gitdeploy
  class SimpleDeployment < Deployment
    include BuildReadme
    attr_accessor :exclude, :delete

    def initialize(options = {})
      super(options)

      @exclude = options[:exclude]
      @delete  = options[:delete]

      @steps = [:build_readme, :ensure_dest_dir, :deploy_files, :clean_readme]
    end

    def ensure_dest_dir
      Dir.ensure(destination)
    end

    def deploy_files
      puts "Deploying to #{destination.path} on #{destination.host} ..."

      options = {}
      (options[:options] ||= {})[:exclude] = exclude if exclude
      (options[:flags] ||= []) << :e if delete

      Dir.sync(source, destination, options)
    end
  end
end
