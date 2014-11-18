require 'gitdeploy/version'
require 'gitdeploy/git'
require 'gitdeploy/deployment'
require 'gitdeploy/deployments/archive_deployment'
require 'gitdeploy/deployments/demo_deployment'
require 'gitdeploy/deployments/rsync_deployment'

require 'facets'

module Gitdeploy
  class GitlabConfig < Struct.new(:host, :username, :password)
    def sign_in_url
      "https://#{self.host}/users/sign_in"
    end

    def network_url
      "https://#{self.host}/#{Gitdeploy.customer}/#{Gitdeploy.project}/network/develop.json"
    end
  end

  class << self
    attr_accessor :customer, :project, :gitlab, :deployments
  end

  def self.load_config(file)
    config_path = File.expand_path(file, Dir.pwd)
    unless File.exists?(config_path)
      $stderr.puts 'Please add a gitdeploy.yml file to your project.'
      exit
    end
    config = YAML.load(File.read(config_path))

    @customer = config['customer']
    @project  = config['project']
    @gitlab   = GitlabConfig.new(config['gitlab']['host'],
                                  config['gitlab']['username'],
                                  config['gitlab']['password'])
    @deployments = config['deployments'].map do |deployment|
      deployment.symbolize_keys
    end
  end

  def self.deployments; @deployments; end
end
