module Gitdeploy
  class Dir
    class << self
      def sync(src, dst)
        case dst.protocol
        when 'ftps', 'ftp', 'sftp' then Gitdeploy::Protocols::FTPS.sync_directory(src, dst)
        when 'ssh'                 then Gitdeploy::Protocols::SSH.sync_directory(src, dst)
        when nil                   then Gitdeploy::Protocols::Local.sync_directory(src, dst)
        else throw UnknownProtocolError, dst.protocol
        end
      end

      def ensure(path)
        case path.protocol
        when 'ftps', 'ftp', 'sftp' then Gitdeploy::Protocols::FTPS.ensure_directory(path)
        when 'ssh'                 then Gitdeploy::Protocols::SSH.ensure_directory(path)
        when nil                   then Gitdeploy::Protocols::Local.ensure_directory(path)
        else throw UnknownProtocolError, path.protocol
        end
      end

      def ls(path)
        case path.protocol
        when 'ftps', 'ftp', 'sftp' then Gitdeploy::Protocols::FTPS.list_directory(path)
        when 'ssh'                 then Gitdeploy::Protocols::SSH.list_directory(path)
        when nil                   then Gitdeploy::Protocols::Local.list_directory(path)
        else throw UnknownProtocolError, path.protocol
        end
      end

      def clean(path)
        case path.protocol
        when 'ftps', 'ftp', 'sftp' then Gitdeploy::Protocols::FTPS.clean_directory(path)
        when 'ssh'                 then Gitdeploy::Protocols::SSH.clean_directory(path)
        when nil                   then Gitdeploy::Protocols::Local.clean_directory(path)
        else throw UnknownProtocolError, path.protocol
        end
      end
    end
  end
end
