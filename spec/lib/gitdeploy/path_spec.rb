describe Gitdeploy::Path do
  describe 'initialization' do
    describe 'via absolute path' do
      subject { Gitdeploy::Path.new('/some/absolute/path') }

      it { expect(subject.protocol).to be_nil }
      it { expect(subject.user).to be_nil }
      it { expect(subject.password).to be_nil }
      it { expect(subject.host).to be_nil }
      it { expect(subject.port).to be_nil }
      it { expect(subject.path).to eq '/some/absolute/path' }
    end

    describe 'via relative path' do
      subject { Gitdeploy::Path.new('some/relative/path') }

      it { expect(subject.protocol).to be_nil }
      it { expect(subject.user).to be_nil }
      it { expect(subject.password).to be_nil }
      it { expect(subject.host).to be_nil }
      it { expect(subject.port).to be_nil }
      it { expect(subject.path).to eq File.join(Dir.pwd, 'some/relative/path') }
    end

    describe 'via path with host' do
      subject { Gitdeploy::Path.new("velalu.qa:/remote/path") }

      it { expect(subject.protocol).to eq 'ssh' }
      it { expect(subject.user).to be_nil }
      it { expect(subject.password).to be_nil }
      it { expect(subject.host).to eq 'velalu.qa' }
      it { expect(subject.port).to be_nil }
      it { expect(subject.path).to eq '/remote/path' }
    end

    describe 'via path with host and port' do
      subject { Gitdeploy::Path.new("velalu.qa:21:/remote/path") }

      it { expect(subject.protocol).to eq 'ssh' }
      it { expect(subject.user).to be_nil }
      it { expect(subject.password).to be_nil }
      it { expect(subject.host).to eq 'velalu.qa' }
      it { expect(subject.port).to eq 21 }
      it { expect(subject.path).to eq '/remote/path' }
    end

    describe 'via path with user and host' do
      subject { Gitdeploy::Path.new("user@velalu.qa:/remote/path") }

      it { expect(subject.protocol).to eq 'ssh' }
      it { expect(subject.user).to eq 'user' }
      it { expect(subject.password).to be_nil }
      it { expect(subject.host).to eq 'velalu.qa' }
      it { expect(subject.port).to be_nil }
      it { expect(subject.path).to eq '/remote/path' }
    end

    describe 'via path with user, host and port' do
      subject { Gitdeploy::Path.new("user@velalu.qa:21:/remote/path") }

      it { expect(subject.protocol).to eq 'ssh' }
      it { expect(subject.user).to eq 'user' }
      it { expect(subject.password).to be_nil }
      it { expect(subject.host).to eq 'velalu.qa' }
      it { expect(subject.port).to eq 21 }
      it { expect(subject.path).to eq '/remote/path' }
    end

    describe 'via path with user, password and host' do
      subject { Gitdeploy::Path.new("user:password@velalu.qa:/remote/path") }

      it { expect(subject.protocol).to eq 'ssh' }
      it { expect(subject.user).to eq 'user' }
      it { expect(subject.password).to eq 'password' }
      it { expect(subject.host).to eq 'velalu.qa' }
      it { expect(subject.port).to be_nil }
      it { expect(subject.path).to eq '/remote/path' }
    end

    describe 'via path with user, password, host and port' do
      subject { Gitdeploy::Path.new("user:password@velalu.qa:21:/remote/path") }

      it { expect(subject.protocol).to eq 'ssh' }
      it { expect(subject.user).to eq 'user' }
      it { expect(subject.password).to eq 'password' }
      it { expect(subject.host).to eq 'velalu.qa' }
      it { expect(subject.port).to eq 21 }
      it { expect(subject.path).to eq '/remote/path' }
    end

    describe 'via path with IP' do
      subject { Gitdeploy::Path.new("100.100.100.100:/remote/path") }

      it { expect(subject.protocol).to eq 'ssh' }
      it { expect(subject.user).to be_nil }
      it { expect(subject.password).to be_nil }
      it { expect(subject.host).to eq '100.100.100.100' }
      it { expect(subject.port).to be_nil }
      it { expect(subject.path).to eq '/remote/path' }
    end

    describe 'via path with IP and port' do
      subject { Gitdeploy::Path.new("100.100.100.100:21:/remote/path") }

      it { expect(subject.protocol).to eq 'ssh' }
      it { expect(subject.user).to be_nil }
      it { expect(subject.password).to be_nil }
      it { expect(subject.host).to eq '100.100.100.100' }
      it { expect(subject.port).to eq 21 }
      it { expect(subject.path).to eq '/remote/path' }
    end

    describe 'via path with user and IP' do
      subject { Gitdeploy::Path.new("user@100.100.100.100:/remote/path") }

      it { expect(subject.protocol).to eq 'ssh' }
      it { expect(subject.user).to eq 'user' }
      it { expect(subject.password).to be_nil }
      it { expect(subject.host).to eq '100.100.100.100' }
      it { expect(subject.port).to be_nil }
      it { expect(subject.path).to eq '/remote/path' }
    end

    describe 'via path with user, IP and port' do
      subject { Gitdeploy::Path.new("user@100.100.100.100:21:/remote/path") }

      it { expect(subject.protocol).to eq 'ssh' }
      it { expect(subject.user).to eq 'user' }
      it { expect(subject.password).to be_nil }
      it { expect(subject.host).to eq '100.100.100.100' }
      it { expect(subject.port).to eq 21 }
      it { expect(subject.path).to eq '/remote/path' }
    end

    describe 'via path with user, password and IP' do
      subject { Gitdeploy::Path.new("user:password@100.100.100.100:/remote/path") }

      it { expect(subject.protocol).to eq 'ssh' }
      it { expect(subject.user).to eq 'user' }
      it { expect(subject.password).to eq 'password' }
      it { expect(subject.host).to eq '100.100.100.100' }
      it { expect(subject.port).to be_nil }
      it { expect(subject.path).to eq '/remote/path' }
    end

    describe 'via path with user, password, IP and port' do
      subject { Gitdeploy::Path.new("user:password@100.100.100.100:21:/remote/path") }

      it { expect(subject.protocol).to eq 'ssh' }
      it { expect(subject.user).to eq 'user' }
      it { expect(subject.password).to eq 'password' }
      it { expect(subject.host).to eq '100.100.100.100' }
      it { expect(subject.port).to eq 21 }
      it { expect(subject.path).to eq '/remote/path' }
    end

    describe 'via path with protocol, user, password and host' do
      subject { Gitdeploy::Path.new("ftp://user:password@100.100.100.100:/remote/path") }

      it { expect(subject.protocol).to eq 'ftp' }
      it { expect(subject.user).to eq 'user' }
      it { expect(subject.password).to eq 'password' }
      it { expect(subject.host).to eq '100.100.100.100' }
      it { expect(subject.port).to be_nil }
      it { expect(subject.path).to eq '/remote/path' }
    end

    describe 'via path with protocol, user, password, host and port' do
      subject { Gitdeploy::Path.new("ftp://user:password@100.100.100.100:21:/remote/path") }

      it { expect(subject.protocol).to eq 'ftp' }
      it { expect(subject.user).to eq 'user' }
      it { expect(subject.password).to eq 'password' }
      it { expect(subject.host).to eq '100.100.100.100' }
      it { expect(subject.port).to eq 21 }
      it { expect(subject.path).to eq '/remote/path' }
    end

    describe 'via object' do
      subject do
        Gitdeploy::Path.new(
          path: 'wrong://wrong:wrong@wrong:10:/correct/path',
          protocol: 'correct',
          user: 'correct',
          password: 'correct',
          host: 'correct',
          port: 21
        )
      end

      it { expect(subject.protocol).to eq 'correct' }
      it { expect(subject.user).to eq 'correct' }
      it { expect(subject.password).to eq 'correct' }
      it { expect(subject.host).to eq 'correct' }
      it { expect(subject.port).to eq 21 }
      it { expect(subject.path).to eq '/correct/path' }
    end
  end

  describe 'initializing with globally defined auth' do
    subject { Gitdeploy::Path.new('ftp://jenkins@demo.foo.com:/remote/path') }

    it 'should set the password from global config' do
      expect(subject.password).to eq 'passwordExtraordinaire'
    end
  end

  describe '#to_s' do
    subject { Gitdeploy::Path.new('ftp://jenkins@demo.foo.com:21:/remote/path') }

    it 'should set the password from global config' do
      expect(subject['[$protocol://][$user[:$password]@][$host][:$port][$path]'])
        .to eq 'ftp://jenkins:passwordExtraordinaire@demo.foo.com:21/remote/path'
    end
  end
end
