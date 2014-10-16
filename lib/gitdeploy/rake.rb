require 'shellwords'
require 'net/http'
require 'tempfile'
require 'yaml'

require 'gitdeploy/git'

@path = File.expand_path(Dir.pwd)
@git = Git.new(@path)

def project_config
  @project_config ||= begin
    config_path = File.expand_path('gitdeploy.yml', Dir.pwd)
    unless File.exists?(config_path)
      $stderr.write "Please add a gitdeploy.yml file to your project.\n"
      exit
    end
    YAML.load(File.read(config_path))
  end
end

def project_name
  @project_name ||= "#{project_config['customer']}-#{project_config['project']}"
end

def package_name
  @package_name ||= begin
    package_name = "#{project_name}_#{@git.branch_name}"
    if @git.tagged?
      package_name << "_#{@git.tag}"
    else
      package_name << "_#{@git.rev[0..6]}"
    end
    package_name << '.zip'
  end
end

def gitdeploy_config
  @gitdeploy_config ||= begin
    match = /(?<host>[^:]+)(:(?<path>.+))?/.match(project_config['gitdeploy'])
    { host: match[:host], path: match[:path] || '.' }
  end
end

def gitdeploy_host
  gitdeploy_config[:host]
end

def gitdeploy_project_path
  @deploy_path ||= File.join(gitdeploy_config[:path], 'projects', project_name)
end

def singleton?
  @singleton ||= project_config['singleton'] == true
end

def key
  @key ||= `ssh #{gitdeploy_host} ls #{gitdeploy_project_path}/metadata`.strip
end

def gitdeploy_metadata_path
  @gitdeploy_metadata_path ||= File.join(gitdeploy_project_path, 'metadata', key)
end

def gitdeploy_deployments_path
  @gitdeploy_deployments_path ||= File.join(gitdeploy_project_path, 'deployments')
end

def gitdeploy_commits_json_path
  @gitdeploy_commits_json_path ||= File.join(gitdeploy_metadata_path, 'commits.json')
end

def gitdeploy_deployments_json_path
  @gitdeploy_deployments_json_path ||= File.join(gitdeploy_metadata_path, 'deployments.json')
end

namespace :gitdeploy do
  namespace :build do
    desc 'Create changelog based on git history and append it to README.md.'
    task :changelog do
      changelog = "## Changelog\n"
      tags = `git tag -l`.split("\n")
      tags.map! { |v| Gem::Version.new(v) }
      tags.sort!
      tags.reverse_each do |tag|
        meta, message = `git cat-file -p \`git rev-parse #{tag}\``.split("\n\n", 2)
        if meta.include?('tagger ')
          changelog << "\n"
          changelog << "### #{tag}\n"
          changelog << "\n"
          changelog << message
        end
      end
      File.open('CHANGELOG', 'w+') { |f| f << changelog }
      `git checkout -- README.md`
      File.open('README.md', 'a+') { |f| f << "\n" << changelog }
    end

    desc 'Zip everything into an archive.'
    task :archive => ['build:changelog'] do
      files = Dir["**/*"].select { |file| file !~ /\.sass-cache|\.git|node_modules/ }
      puts "Packaging archive #{package_name} ..."
      sh "zip -r9 #{package_name} #{files.join(' ')}"
    end
  end

  desc 'Copy files to configured locations.'
  task :deploy => ['deploy:commits', 'deploy:rotate', 'deploy:public_folder', 'deploy:index', 'deploy:archive', 'deploy:clean']

  namespace :deploy do
    desc 'Push commits metadata to GitDeploy setup.'
    task :commits do
      puts "Fetching commits metadata from gitlab ..."
      http = Net::HTTP.new(project_config['gitlab']['host'], 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      # get auth token
      response = http.get('/users/sign_in')
      auth_token = /<meta content="([^"]*)" name="csrf-token" \/>/.match(response.body)[1]
      cookie = /(_gitlab_session=[^;]*);/.match(response['set-cookie'])[1]

      # log in
      request = Net::HTTP::Post.new('/users/sign_in')
      request['Cookie'] = cookie
      request.set_form_data({ 'user[login]' => project_config['gitlab']['username'], 'user[password]' => project_config['gitlab']['password'], authenticity_token: auth_token })
      response = http.request(request)
      cookie_match = /(_gitlab_session=[^;]*);/.match(response['set-cookie'])
      if cookie_match.nil?
         raise 'Gitlab login failed. Please check your gitlab settings in gitdeploy.yml.'
      else
        cookie = cookie_match[1]

        # fetch json
        request = Net::HTTP::Get.new("/#{project_config['customer']}/#{project_config['project']}/network/develop.json")
        request['Cookie'] = cookie
        json = http.request(request).body

        tmp_file = Tempfile.new('commits.json')
        tmp_file.write(json)
        tmp_file.flush

        puts "Writing commits metadata to #{gitdeploy_commits_json_path}"
        sh "rsync -rvz -p --chmod=og=rx #{tmp_file.path} #{gitdeploy_host}:#{gitdeploy_commits_json_path}"

        tmp_file.close
        tmp_file.unlink
      end
    end

    desc 'Remove old deployments when in singleton mode'
    task :rotate do
      if singleton?
        puts "Remove all present deployments"
        `ssh #{gitdeploy_host} "echo [] > #{gitdeploy_deployments_json_path}"`
        `ssh #{gitdeploy_host} find #{gitdeploy_deployments_path} -mindepth 1 -maxdepth 1 -type d -exec rm -R {} +`
      end
    end

    task :public_folder do
      path = "#{gitdeploy_host}:#{gitdeploy_deployments_path}/#{@git.rev[0..6]}"
      puts "Deploying to #{path} ..."
      sh "rsync -rvz --delete -p --chmod=og=rx public/ #{path}"
    end

    desc 'Push deployments metadata to GitDeploy setup.'
    task :index do
      puts "Fetching present deployments from #{gitdeploy_host} ..."
      deployments = `ssh #{gitdeploy_host} ls #{gitdeploy_deployments_path}`.split("\n").select{|p| p =~ /^[a-z0-9]*$/}.join('", "')
      deployments = "[\"#{deployments}\"]"

      puts "Writing #{gitdeploy_deployments_json_path} file on #{gitdeploy_host} ..."
      `echo #{Shellwords.escape(deployments)} | ssh #{gitdeploy_host} "cat > #{gitdeploy_deployments_json_path}"`
    end

    desc 'Copy project snapshot to configured location.'
    task :archive do
      if project_config['archive'] && (!project_config['archive']['tagged_only'] || @git.tagged?)
        Rake::Task['gitdeploy:build:archive'].invoke
        puts "Deploying to #{project_config['archive']['path']} ..."
        mkdir_p(File.dirname(project_config['archive']['path']))
        cp(package_name, project_config['archive']['path'])
        rm_f(package_name)
      end
    end

    desc 'Reset the readme file.'
    task :clean do
      rm_f('CHANGELOG')
      sh 'git checkout -- README.md'
    end
  end
end
