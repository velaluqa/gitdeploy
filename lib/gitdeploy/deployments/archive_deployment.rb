# coding: utf-8
require 'gitdeploy/builder/build_readme'

require 'fileutils'

module Gitdeploy
  class ArchiveDeployment < Deployment
    include BuildReadme

    def initialize(options = {})
      super(options)
      @steps = [:build_readme, :build_archive, :deploy_archive, :clean_archive, :clean_readme]
    end

    def package_name
      @package_name ||= replace_variables(File.basename(destination.path))
    end

    def build_archive
      puts "Packaging archive #{package_name} ..."
      files = Dir["#{File.join(source, "")}**/*"].select { |file| file !~ /\.sass-cache|\.git|node_modules/ }
      system "zip -r9 #{package_name} #{files.join(' ')}"
    end

    def deploy_archive
      puts "Deploying to #{destination.path} ..."
      FileUtils.mkdir_p(File.dirname(destination.path))
      FileUtils.cp(package_name, destination.path)
    end

    def clean_archive
      puts "Removing #{package_name} ..."
      FileUtils.rm_f(package_name)
    end
  end
end
