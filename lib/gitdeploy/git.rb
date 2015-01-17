class Git
  def initialize(cwd)
    @cwd = cwd
  end

  def branch
    @branch ||= (ENV['GIT_BRANCH'] ||
                 `cd #{@cwd}; git rev-parse --abbrev-ref HEAD`.strip)
  end

  def branch_name
    @branch_name ||= branch.gsub(%r{^[^/]+/}, '')
  end

  def tag
    stdout = `cd #{@cwd}; git describe --tags 2>&1`
    status = $?
    @tag ||= stdout.strip if status.exitstatus == 0
  end

  def rev
    @rev ||= (ENV['GIT_COMMIT'] || `cd #{@cwd}; git rev-parse HEAD`.strip)
  end

  def tagged?
    tag && tag != '' && tag !~ /^(.*)-([0-9]+)-([0-9a-z]+)$/
  end
end
