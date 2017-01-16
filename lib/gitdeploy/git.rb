require 'English'

module Gitdeploy
  class Git
    class << self
      def pwd
        @pwd ||= ::File.expand_path(::Dir.pwd)
      end

      def branch
        @branch ||= (ENV['GIT_BRANCH'] ||
                     `cd #{pwd}; git branch -a -v --abbrev=40 | grep #{rev} | awk '{print $1}' | grep -v '*' | head -n1 | awk -F '/' '{print $NF}'`.strip)
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
end
