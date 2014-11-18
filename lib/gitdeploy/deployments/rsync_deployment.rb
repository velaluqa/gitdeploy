require 'gitdeploy/builder/build_readme'

module Gitdeploy
  class RsyncDeployment < Deployment
    include BuildReadme

    def initialize(options = {})
      super(options)
      @steps = [:build_readme, :ensure_dest_dir, :deploy_files, :clean_readme]
    end

    def ensure_dest_dir
      ensure_directory(destination)
    end

    def deploy_files
      puts "Deploying to #{destination.full} ..."
      system "rsync -rvz --delete -p --chmod=og=rx #{source} #{destination.full}"
    end
  end
end
