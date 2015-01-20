module Gitdeploy
  class Dir
    class << self
      def sync(src, dst, options = {})
        case dst.protocol
        when 'ftps', 'ftp', 'sftp' then Gitdeploy::Protocols::FTP.sync_directory(src, dst, options)
        when 'ssh'                 then Gitdeploy::Protocols::SSH.sync_directory(src, dst, options)
        when nil                   then Gitdeploy::Protocols::Local.sync_directory(src, dst, options)
        else throw UnknownProtocolError, dst.protocol
        end
      end

      def ensure(path)
        case path.protocol
        when 'ftps', 'ftp', 'sftp' then Gitdeploy::Protocols::FTP.ensure_directory(path)
        when 'ssh'                 then Gitdeploy::Protocols::SSH.ensure_directory(path)
        when nil                   then Gitdeploy::Protocols::Local.ensure_directory(path)
        else throw UnknownProtocolError, path.protocol
        end
      end

      def ls(path)
        case path.protocol
        when 'ftps', 'ftp', 'sftp' then Gitdeploy::Protocols::FTP.list_directory(path)
        when 'ssh'                 then Gitdeploy::Protocols::SSH.list_directory(path)
        when nil                   then Gitdeploy::Protocols::Local.list_directory(path)
        else throw UnknownProtocolError, path.protocol
        end
      end

      def clean(path)
        case path.protocol
        when 'ftps', 'ftp', 'sftp' then Gitdeploy::Protocols::FTP.clean_directory(path)
        when 'ssh'                 then Gitdeploy::Protocols::SSH.clean_directory(path)
        when nil                   then Gitdeploy::Protocols::Local.clean_directory(path)
        else throw UnknownProtocolError, path.protocol
        end
      end
    end
  end
end
