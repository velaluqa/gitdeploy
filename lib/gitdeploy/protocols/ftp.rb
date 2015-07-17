module Gitdeploy
  module Protocols
    module FTP
      class << self
        PATH_SPEC = "[$protocol://][$user[:$password]@][$host][:$port][$path]"

        def lftp(command)
          `lftp -c #{Shellwords.escape(command)}`
        end

        def sync_directory(src, dst, options = {})
          flags = Command.flags(options[:flags])
          opts  = Command.opts(options[:options])

          lftp "mirror #{flags}#{opts}-R '#{src}' '#{dst[PATH_SPEC]}'"
        end

        def ensure_directory(dst)
          lftp "mkdir -p -f '#{dst[PATH_SPEC]}'"
        end

        def list_directory(dst)
          lftp "ls '#{dst[PATH_SPEC]}'"
        end

        def remove_directory(dst)
          lftp "rm -r '#{dst[PATH_SPEC]}'"
        end

        def clear_directory(dst)
          remove_directory(dst)
          ensure_directory(dst)
        end

        def file_exists?(dst)
          lftp "glob --exist '#{dst[PATH_SPEC]}'"
          $?.exitstatus == 0
        end

        def write_file(dst, content)
          f = Tempfile.new('gitdeploy')
          f.puts content
          f.flush

          lftp("put '#{f.path}' -o '#{dst[PATH_SPEC]}'")

          f.close
          f.unlink
        end

        def read_file(dst)
          lftp "cat '#{dst[PATH_SPEC]}'"
        end

        def copy_file(src, dst)
          lftp("put '#{src}' -o '#{dst[PATH_SPEC]}'")
        end
      end
    end
  end
end
