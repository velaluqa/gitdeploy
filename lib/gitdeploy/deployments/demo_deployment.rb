require 'mechanize'

module Gitdeploy
  class DemoDeployment < Deployment
    attr_accessor :gitlab, :links

    def initialize(options = {})
      super(options)

      gitlab = case options[:gitlab]
               when Hash then options[:gitlab]
               when String then Gitdeploy.global.gitlab(options[:gitlab])
               end
      throw "No GitlabConfig given" unless gitlab
      @gitlab = GitlabConfig.new(gitlab)

      @links = options[:links]

      @steps = [
        :ensure_dest_dirs,
        :rotate,
        :deploy_commits,
        :deploy_files,
        :deploy_links,
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

    def deployments_json_path
      @deployments_json_path ||= metadata_dir.join('deployments.json')
    end

    def commits_json
      @commits_json ||= metadata_dir.join('commits.json')
    end

    def links_json_path
      @links_json_path ||= deployment_dir.join('.gitdeploy_links.json')
    end

    ## Helpers
    def deployments_json
      @deployments_json ||=
        begin
          ds = {}
          Dir.ls(deployments_dir).each do |rev_dir|
            if rev_dir =~ /^[a-z0-9]*$/
              links_path = deployments_dir.join(rev_dir).join('.gitdeploy_links.json')
              if File.exists?(links_path)
                begin
                  ds[rev_dir] = { links: JSON.parse(File.read(links_path)) }
                rescue
                  puts "Ignoring invalid JSON in #{links_path['[$path][ on $host]']}"
                end
              end
              ds[rev_dir] ||= {}
            end
          end
          ds
        end.to_json
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

    def links_json
      puts Git.rev
      @links_json ||=
        begin
          links = {}
          @links.keys.each {|key| links[key] = replace_variables(@links[key])}
          links.to_json
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
      Dir.sync(sources, deployment_dir)
    end

    def deploy_links
      unless @links.nil?
        puts "Writing #{links_json_path['[$path][ on $host]']} ..."
        File.write(links_json_path, links_json)
      end
    end

    def deploy_index
      puts "Writing #{deployments_json_path['[$path][ on $host]']} ..."
      File.write(deployments_json_path, deployments_json)
    end
  end
end
