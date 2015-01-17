describe Gitdeploy::GlobalConfig do
  describe '#auth' do
    it 'returns the auth for given host' do
      expect(Gitdeploy.global.auth(user: 'jenkins', host: 'demo.foo.com'))
        .to eq(password: 'passwordExtraordinaire')
    end

    it 'returns nil for non-existing config' do
      expect(Gitdeploy.global.auth(host: 'other.server.com')).to be_nil
    end
  end

  describe '#gitlab' do
    it 'returns gitlab config for given key' do
      expect(Gitdeploy.global.gitlab('testGitlab'))
        .to eq(host: 'gitlab.foo.com',
               username: 'jenkins',
               password: 'passwordExtraordinaire')
    end

    it 'returns nil for non-existing config' do
      expect(Gitdeploy.global.gitlab('otherGitlab')).to be_nil
    end
  end
end
