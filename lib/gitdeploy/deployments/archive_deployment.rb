require 'fileutils'

module Gitdeploy
  class ArchiveDeployment < Deployment
    attr_accessor :exclude_regex

    def initialize(options = {})
      super(options)

      @exclude_regex = /#{options[:exclude_regex]}/

      @steps = [:build_archive, :deploy_archive, :clean_archive]
    end

    def package_file
      @package_file ||= ::File.basename(destination.path)
    end

    def build_archive
      puts "Packaging archive #{package_file} ..."
      files = sources.map do |source|
        ::Dir["#{::File.join(source, '')}**/*"].select { |file| file !~ exclude_regex }
      end.flatten
      system "zip -q -r9 #{package_file} #{Shellwords.join(files)}"
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
