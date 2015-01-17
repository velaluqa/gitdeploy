# coding: utf-8
require 'gitdeploy/builder/build_readme'

require 'fileutils'

module Gitdeploy
  class ArchiveDeployment < Deployment
    include BuildReadme

    attr_accessor :exclude_regex

    def initialize(options = {})
      super(options)

      @exclude_regex = /#{options[:exclude_regex]}/

      @steps = [
        :build_readme,
        :build_archive,
        :deploy_archive,
        :clean_archive,
        :clean_readme
      ]
    end

    def package_file
      @package_file ||= ::File.basename(destination.path)
    end

    def build_archive
      puts "Packaging archive #{package_file} ..."
      files = ::Dir["#{::File.join(source, '')}**/*"].select { |file| file !~ exclude_regex }
      system "zip -r9 #{package_file} #{files.join(' ')}"
    end

    def deploy_archive
      puts "Deploying to #{destination['[$path][ on $host]']} ..."
      FileUtils.mkdir_p(::File.dirname(destination.path))
      File.copy(package_file, destination)
    end

    def clean_archive
      puts "Removing #{package_file} ..."
      FileUtils.rm_f(package_file)
    end
  end
end
