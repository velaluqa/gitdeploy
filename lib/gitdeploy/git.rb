class Git
  def initialize(cwd)
    @cwd = cwd
  end

  def branch
    @branch ||= (ENV['GIT_BRANCH'] || `cd #{@cwd}; git rev-parse --abbrev-ref HEAD`.strip)
  end

  def branch_name
    @branch_name ||= branch.gsub(/^[^\/]+\//, '')
  end

  def tag
    stdout = `cd #{@cwd}; git describe --tags 2>&1`
    status = $?
    if status.exitstatus == 0
      @tag ||= stdout.strip
    else
      nil
    end
  end

  def rev
    @rev ||= (ENV['GIT_COMMIT'] || `cd #{@cwd}; git rev-parse HEAD`.strip)
  end

  def tagged?
    tag && tag != '' && tag !~ /^(.*)-([0-9]+)-([0-9a-z]+)$/
  end
end
