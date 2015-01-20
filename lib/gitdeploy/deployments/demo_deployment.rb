require 'mechanize'
require 'pry'

module Gitdeploy
  class DemoDeployment < Deployment
    attr_accessor :gitlab

    def initialize(options = {})
      super(options)

      gitlab = case options[:gitlab]
               when Hash then options[:gitlab]
               when String then Gitdeploy.global.gitlab(options[:gitlab])
               end
      throw "No GitlabConfig given" unless gitlab
      @gitlab = GitlabConfig.new(gitlab)

      @steps = [
        :ensure_dest_dirs,
        :rotate,
        :deploy_commits,
        :deploy_files,
        :deploy_index
      ]
    end

    def project_dir
      @project_dir ||= destination.join('projects', project_name, '')
    end

    def deployments_dir
      @deployments_dir ||= project_dir.join('deployments', '')
    end

    def deployment_dir
      @deployment_dir ||= deployments_dir.join(Git.rev[0..6], '')
    end

    def key
      keys = Dir.ls(project_dir.join('metadata'))
      if keys.empty?
        @key = [('a'..'z'),('A'..'Z'),('0'..'9')].map(&:to_a).flatten.shuffle[0,8].join
      else
        @key = keys.first
      end
    end

    def metadata_dir
      @metadata_dir ||= project_dir.join('metadata', key, '')
    end

    def deployments_json
      @deployments_json ||= metadata_dir.join('deployments.json')
    end

    def commits_json
      @commits_json ||= metadata_dir.join('commits.json')
    end

    ## Helpers
    def deployments
      Dir.ls(deployments_dir).select { |p| p =~ /^[a-z0-9]*$/ }
    end

    def commits
      @commits ||=
        begin
          puts "Fetching commits metadata from gitlab ..."
          a = Mechanize.new
          a.get(gitlab.sign_in_url) do |page|
            page.form_with(action: '/users/sign_in') do |f|
              f.field_with(name:'user[login]').value = gitlab.username
              f.field_with(name:'user[password]').value = gitlab.password
            end.click_button
          end
          page = a.get(gitlab.network_url)
          page.body
        end
    end

    ## Tasks
    def ensure_dest_dirs
      Dir.ensure(deployment_dir)
      Dir.ensure(metadata_dir)
    end

    def rotate
      if rotate?
        puts 'Remove all present deployments'
        File.write(deployments_json, '[]')
        Dir.clean(deployments_dir)
      end
    end

    def deploy_commits
      puts "Writing #{commits_json['[$path][ on $host]']} ..."
      File.write(commits_json, commits)
    end

    def deploy_files
      puts "Deploying to #{deployment_dir['[$path][ on $host]']} ..."
      Dir.sync(source, deployment_dir)
    end

    def deploy_index
      puts "Writing #{deployments_json['[$path][ on $host]']} ..."
      File.write(deployments_json, deployments.to_json)
    end
  end
end
