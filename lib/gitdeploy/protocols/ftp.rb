module Gitdeploy
  module Protocols
    module FTP
      class << self
        PATH_SPEC = "[$protocol://][$user[:$password]@][$host][:$port][$path]"

        def lftp(command)
          `lftp -c #{Shellwords.escape(command)}`
        end

        def sync_directories(sources, dst, options = {})
          if sources.length > 1 and options[:flags] and (options[:flags].include?('e') or options[:flags].include?('delete'))
            throw 'Deleting files not present at remote site is not supported with multiple sources.'
          end

          flags = Command.flags(options[:flags])
          opts  = Command.opts(options[:options])

          sources.each do |src|
            lftp "mirror #{flags}#{opts}-R '#{src}' '#{dst[PATH_SPEC]}'"
          end
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
