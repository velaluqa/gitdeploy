require 'gitdeploy/builder/build_readme'

module Gitdeploy
  class SimpleDeployment < Deployment
    include BuildReadme

    def initialize(options = {})
      super(options)
      @steps = [:build_readme, :ensure_dest_dir, :deploy_files, :clean_readme]
    end

    def ensure_dest_dir
      Dir.ensure(destination)
    end

    def deploy_files
      puts "Deploying to #{destination.path} on #{destination.host} ..."
      Dir.sync(source, destination)
    end
  end
end
