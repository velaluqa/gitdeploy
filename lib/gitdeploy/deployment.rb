module Gitdeploy
  class UnknownDeploymentTypeError < Exception; end

  class Deployment
    attr_accessor :git, :path, :type, :source, :destination, :refs, :branch

    class Path < Struct.new(:user, :host, :path)
      def initialize(path)
        match = /(?<user>[^@\/]+)?@?(?<host>[^@:\/]+)?(:?(?<path>.+))?/.match(path)
        self.user = match[:user]
        self.host = match[:host]
        self.path = match[:path] || '.'
      end

      def join(*args)
        res = self.clone
        args.unshift(res.path)
        res.path = File.join(*args)
        res
      end

      def full_host
        if host
          if user
            "#{user}@#{host}"
          else
            "#{host}"
          end
        end
      end

      def full
        full = ""
        full += "#{user}@" if user
        full += "#{host}:" if host
        full += path
      end

      def to_s
        full
      end
    end

    def list_directory(dir)
      cmd = "ls -1 #{dir.path}"
      cmd = "ssh #{dir.full_host} #{cmd}" if dir.full_host
      res = `#{cmd}`
      if $? == 0
        res.split("\n").map(&:strip)
      else
        []
      end
    end

    def ensure_directory(dir)
      cmd = "mkdir -p #{dir.path}"
      cmd = "ssh #{dir.full_host} #{cmd}" if dir.full_host
      `#{cmd}`
    end

    def write_file(path, content)
      f = Tempfile.new('gitdeploy')
      f.puts content
      f.flush
      `rsync -rvz -p --chmod=og=rx #{f.path} #{path}`
      f.close
      f.unlink
    end

    def clean_directory(dir)
      cmd = "find #{dir.path} -mindepth 1 -maxdepth 1 -type d -exec rm -R {} +"
      cmd = "ssh #{dir.full_host} #{cmd}" if dir.host
      `#{cmd}`
    end

    def initialize(options = {})
      @path = File.expand_path(Dir.pwd)
      @git = Git.new(@path)

      @steps       = []
      @type        = options[:type]
      @refs        = options[:refs] || 'all'
      @branch      = options[:branch] || '.*'
      @rotate      = options[:rotate]
      @source      = File.join(File.expand_path(options[:source]), '')
      @destination = Path.new(replace_variables(options[:destination]))
    end

    def rotate?
      @rotate
    end

    def match?
      if /#{@branch}/.match(@git.branch_name)
        if @refs == 'tag' && @git.tag.nil?
          false
        else
          true
        end
      else
        false
      end
    end

    def project_name
      @project_name ||= "#{Gitdeploy.customer}-#{Gitdeploy.project}"
    end

    def dest_path
      @dest_path ||= destination.full
    end

    def dest_dir
      @dest_dir ||= File.dirname(dest_path)
    end

    def deploy
      @steps.each { |step| self.send(step) }
    end

    def replace_variables(str)
      str = str.clone
      str.gsub!('{{customer}}', Gitdeploy.customer)
      str.gsub!('{{project}}', Gitdeploy.project)
      str.gsub!('{{tag}}', git.tag || git.rev)
      str.gsub!('{{tag_or_rev(\[(\d+)\.\.(\d+)\])?}}') do
        if git.tag
          git.tag
        elsif $2 && $3
          git.rev[$2.to_i..$3.to_i]
        else
          git.rev
        end
      end
      str.gsub!(/{{rev(\[(\d+)\.\.(\d+)\])?}}/) do
        if $2 && $3
          git.rev[$2.to_i..$3.to_i]
        else
          git.rev
        end
      end
      str.gsub!('{{branch}}', git.branch_name)
      str
    end
  end
end
