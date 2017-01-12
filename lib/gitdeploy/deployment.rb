module Gitdeploy
  class UnknownDeploymentTypeError < Exception; end
  class UnknownProtocolError < Exception; end

  class Deployment
    attr_accessor :type, :sources, :destination, :refs, :branch

    def initialize(options = {})
      @steps       = []
      @type        = options[:type]
      @refs        = options[:refs] || 'all'
      @branch      = options[:branch] || '.*'
      @rotate      = options[:rotate]
      @sources     = [options[:sources] || options[:source] || '.'].flatten
      @destination = Path.new(options[:destination])
      @destination.path = replace_variables(@destination.path)
    end

    def rotate?
      @rotate
    end

    def match?
      if /#{@branch}/.match(Git.branch)
        if @refs == 'tag' && Git.tag.nil?
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
      str.gsub!('{{tag}}', Git.tag || Git.rev)
      str.gsub!('{{tag_or_rev(\[(\d+)\.\.(\d+)\])?}}') do
        if git.tag
          Git.tag
        elsif $2 && $3
          Git.rev[$2.to_i..$3.to_i]
        else
          Git.rev
        end
      end
      str.gsub!(/{{rev(\[(\d+)\.\.(\d+)\])?}}/) do
        if $2 && $3
          Git.rev[$2.to_i..$3.to_i]
        else
          Git.rev
        end
      end
      str.gsub!('{{branch}}', Git.branch)
      str
    end
  end
end
