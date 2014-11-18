require 'shellwords'
require 'net/http'
require 'tempfile'
require 'yaml'

require 'gitdeploy'

Gitdeploy.load_config('gitdeploy.yml')

# def gitdeploy_host
#   gitdeploy_config[:host]
# end

# def gitdeploy_project_path
#   @deploy_path ||= File.join(gitdeploy_config[:path], 'projects', project_name)
# end

# def singleton?
#   @singleton ||= project_config['singleton'] == true
# end

# def gitdeploy_metadata_path
#   @gitdeploy_metadata_path ||= File.join(gitdeploy_project_path, 'metadata', key)
# end

# def gitdeploy_deployments_path
#   @gitdeploy_deployments_path ||= File.join(gitdeploy_project_path, 'deployments')
# end

# def gitdeploy_commits_json_path
#   @gitdeploy_commits_json_path ||= File.join(gitdeploy_metadata_path, 'commits.json')
# end

# def gitdeploy_deployments_json_path
#   @gitdeploy_deployments_json_path ||= File.join(gitdeploy_metadata_path, 'deployments.json')
# end

namespace :gitdeploy do
  desc 'Copy files to configured locations.'
  task :deploy do
    Gitdeploy.deployments.each do |deployment|
      case deployment[:type]
      when 'demo'    then Gitdeploy::DemoDeployment.new(deployment)
      when 'rsync'   then Gitdeploy::RsyncDeployment.new(deployment)
      when 'archive' then Gitdeploy::ArchiveDeployment.new(deployment)
      else throw UnknownDeploymentTypeError, deployment[:type].inspect
      end.tap do |handler|
        handler.deploy if handler.match?
      end
    end
  end
end

#


#   namespace :deploy do
#     desc 'Push commits metadata to GitDeploy setup.'
#     task :commits do

#     end

#     desc 'Remove old deployments when in singleton mode'
#     task :rotate do
#
#     end

#     task :public_folder do

#     end

#     desc 'Push deployments metadata to GitDeploy setup.'
#     task :index do
#     end

#     desc 'Reset the readme file.'
#     task :clean do
#       rm_f('CHANGELOG')
#       sh 'git checkout -- README.md' if File.exists?('README.md')
#     end
#   end
# end
