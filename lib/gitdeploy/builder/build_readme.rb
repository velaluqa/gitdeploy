module BuildReadme
  def build_readme
    changelog = "## Changelog\n"
    tags = `git tag -l`.split("\n")
    tags.map! do |v|
      begin
        Gem::Version.new(v)
      rescue StandardError
        # The tag might not be of correct version format.
        # In those cases we simply ignore the tag (remove them by compact!).
        nil
      end
    end
    tags.compact!
    tags.sort!
    tags.reverse_each do |tag|
      meta, message = `git cat-file -p \`git rev-parse #{tag}\``.split("\n\n", 2)
      changelog << "\n### #{tag}\n\n#{message}" if meta.include?('tagger ')
    end
    File.open('CHANGELOG', 'w+') { |f| f << changelog }
    if File.exist?('README.md')
      `git checkout -- README.md`
      File.open('README.md', 'a+') { |f| f << "\n" << changelog }
    end
  end

  def clean_readme
    puts 'Removing CHANGELOG'
    FileUtils.rm_f('CHANGELOG')
    `git checkout -- README.md` if File.exist?('README.md')
  end
end
