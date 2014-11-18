require 'mechanize'
require 'pry'

module Gitdeploy
  class DemoDeployment < Deployment
    def initialize(options = {})
      super(options)
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
      @deployment_dir ||= deployments_dir.join(git.rev[0..6], '')
    end

    def key
      keys = list_directory(project_dir.join('metadata'))
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
      list_directory(deployments_dir).select { |p| p =~ /^[a-z0-9]*$/ }
    end

    def commits
      @commits ||=
        begin
          puts "Fetching commits metadata from gitlab ..."
          a = Mechanize.new
          a.get(Gitdeploy.gitlab.sign_in_url) do |page|
            page.form_with(action: '/users/sign_in') do |f|
              f.field_with(name:'user[login]').value = Gitdeploy.gitlab.username
              f.field_with(name:'user[password]').value = Gitdeploy.gitlab.password
            end.click_button
          end
          page = a.get(Gitdeploy.gitlab.network_url)
          page.body
        end
    end

    ## Tasks
    def ensure_dest_dirs
      ensure_directory(deployment_dir)
      ensure_directory(metadata_dir)
    end

    def rotate
      if rotate?
        puts 'Remove all present deployments'
        write_file(deployments_json, '[]')
        clean_directory(deployments_dir)
      end
    end

    def deploy_commits
      puts "Writing #{commits_json} ..."
      write_file(commits_json, commits)
    end

    def deploy_files
      puts "Deploying to #{deployment_dir} ..."
      system "rsync -rvz --delete -p --chmod=og=rx #{source} #{deployment_dir}"
    end

    def deploy_index
      puts "Writing #{deployments_json} ..."
      write_file(deployments_json, deployments.to_json)
    end
  end
end
