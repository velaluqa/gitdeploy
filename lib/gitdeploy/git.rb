require 'English'

class Git
  class << self
    def pwd
      @pwd ||= ::File.expand_path(::Dir.pwd)
    end

    def branch
      @branch ||= (ENV['GIT_BRANCH'] || `cd #{pwd}; git rev-parse --abbrev-ref HEAD`.strip)
    end

    def branch_name
      @branch_name ||= branch.gsub(%r{^[^/]+/}, '')
    end

    def tag
      stdout = `cd #{pwd}; git describe --tags 2>&1`.strip
      status = $CHILD_STATUS
      @tag ||= stdout.strip if status.exitstatus == 0
    end

    def rev
      @rev ||= (ENV['GIT_COMMIT'] || `cd #{pwd}; git rev-parse HEAD`.strip)
    end

    def tagged?
      tag && tag != '' && tag !~ /^(.*)-([0-9]+)-([0-9a-z]+)$/
    end
  end
end
