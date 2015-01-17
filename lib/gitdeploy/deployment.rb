module Gitdeploy
  class UnknownDeploymentTypeError < Exception; end
  class UnknownProtocolError < Exception; end

  class Deployment
    attr_accessor :git, :type, :source, :destination, :refs, :branch

    def initialize(options = {})
      @git = Git.new(::File.expand_path(::Dir.pwd))

      @steps       = []
      @type        = options[:type]
      @refs        = options[:refs] || 'all'
      @branch      = options[:branch] || '.*'
      @rotate      = options[:rotate]
      @source      = ::File.join(::File.expand_path(options[:source]), '')
      @destination = Path.new(options[:destination])
      @destination.path = replace_variables(@destination.path)
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
      @steps.each { |step| send(step) }
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
