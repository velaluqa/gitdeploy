module Gitdeploy
  class File
    class << self
      def copy(src, dst)
        case dst.protocol
        when 'ssh'  then Gitdeploy::Protocols::SSH.copy_file(src, dst)
        when 'ftps' then Gitdeploy::Protocols::FTPS.copy_file(src, dst)
        when nil    then Gitdeploy::Protocols::Local.copy_file(src, dst)
        else throw UnknownProtocolError, path.protocol
        end
      end

      def write(path, content)
        case path.protocol
        when 'ssh'  then Gitdeploy::Protocols::SSH.write_file(path, content)
        when 'ftps' then Gitdeploy::Protocols::FTPS.write_file(path, content)
        when nil    then Gitdeploy::Protocols::Local.write_file(path, content)
        else throw UnknownProtocolError, path.protocol
        end
      end

      def read(path)
        case path.protocol
        when 'ssh'  then Gitdeploy::Protocols::SSH.read_file(path)
        when 'ftps' then Gitdeploy::Protocols::FTPS.read_file(path)
        when nil    then Gitdeploy::Protocols::Local.read_file(path)
        else throw UnknownProtocolError, path.protocol
        end
      end
    end
  end
end
