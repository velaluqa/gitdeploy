module Gitdeploy
  class File
    class << self
      def copy(src, dst)
        case dst.protocol
        when 'ftps', 'ftp', 'sftp' then Gitdeploy::Protocols::FTP.copy_file(src, dst)
        when 'ssh'                 then Gitdeploy::Protocols::SSH.copy_file(src, dst)
        when nil                   then Gitdeploy::Protocols::Local.copy_file(src, dst)
        else throw UnknownProtocolError, path.protocol
        end
      end

      def write(path, content)
        case path.protocol
        when 'ftps', 'ftp', 'sftp' then Gitdeploy::Protocols::FTP.write_file(path, content)
        when 'ssh'                 then Gitdeploy::Protocols::SSH.write_file(path, content)
        when nil                   then Gitdeploy::Protocols::Local.write_file(path, content)
        else throw UnknownProtocolError, path.protocol
        end
      end

      def read(path)
        case path.protocol
        when 'ftps', 'ftp', 'sftp' then Gitdeploy::Protocols::FTP.read_file(path)
        when 'ssh'                 then Gitdeploy::Protocols::SSH.read_file(path)
        when nil                   then Gitdeploy::Protocols::Local.read_file(path)
        else throw UnknownProtocolError, path.protocol
        end
      end

      def exists?(path)
        case path.protocol
        when 'ftps', 'ftp', 'sftp' then Gitdeploy::Protocols::FTP.file_exists?(path)
        when 'ssh'                 then Gitdeploy::Protocols::SSH.file_exists?(path)
        when nil                   then Gitdeploy::Protocols::Local.file_exists?(path)
        else throw UnknownProtocolError, path.protocol
        end
      end
    end
  end
end
