require 'gitdeploy/version'
require 'gitdeploy/git'
require 'gitdeploy/dir'
require 'gitdeploy/file'
require 'gitdeploy/path'
require 'gitdeploy/global_config'
require 'gitdeploy/gitlab_config'
require 'gitdeploy/deployment'
require 'gitdeploy/deployments/simple_deployment'
require 'gitdeploy/deployments/archive_deployment'
require 'gitdeploy/deployments/demo_deployment'
require 'gitdeploy/command'
require 'gitdeploy/protocols/local'
require 'gitdeploy/protocols/ssh'
require 'gitdeploy/protocols/ftp'
require 'gitdeploy/mixins/hash'

require 'facets'

module Gitdeploy
  class << self
    attr_accessor :customer, :project, :global, :deployments

    def load_global(file)
      throw Exception, 'Missing `global_file` options' unless file
      global_file = ::File.expand_path(file, ::Dir.pwd)
      YAML.load(::File.read(global_file)) if ::File.exist?(global_file)
    end

    def load_project(file)
      throw Exception, 'Missing `project_file` options' unless file
      project_file = ::File.expand_path(file, ::Dir.pwd)
      unless ::File.exist?(project_file)
        abort 'Please add a gitdeploy.yml file to your project.'
      end
      YAML.load(::File.read(project_file))
    end

    def load(options = {})
      project = load_project(options[:project_file])
      @customer    = project['customer']
      @project     = project['project']
      @deployments = project['deployments'].map(&:deep_symbolize_keys)

      global  = load_global(options[:global_file])
      @global = GlobalConfig.new(global)
    end
  end
end
