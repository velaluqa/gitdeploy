module BuildReadme
  def build_readme
    changelog = "## Changelog\n"
    tags = `git tag -l`.split("\n")
    tags.map! { |v| Gem::Version.new(v) }
    tags.sort!
    tags.reverse_each do |tag|
      meta, message = `git cat-file -p \`git rev-parse #{tag}\``.split("\n\n", 2)
      if meta.include?('tagger ')
        changelog << "\n"
        changelog << "### #{tag}\n"
        changelog << "\n"
        changelog << message
      end
    end
    File.open('CHANGELOG', 'w+') { |f| f << changelog }
    if File.exists?('README.md')
      `git checkout -- README.md`
      File.open('README.md', 'a+') { |f| f << "\n" << changelog }
    end
  end

  def clean_readme
    puts "Removing CHANGELOG"
    FileUtils.rm_f('CHANGELOG')
    `git checkout -- README.md` if File.exists?('README.md')
  end
end
