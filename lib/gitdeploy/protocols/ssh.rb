module Gitdeploy
  module Protocols
    module SSH
      class << self
        RSYNC_PATH_1 = '[$user@][$host:]'
        RSYNC_PATH_2 = '[$path]'

        def ssh(host, command, options = {})
          (options[:options] ||= {})[:p] = options[:port] if options[:port]

          flags = Command.flags(options[:flags])
          opts  = Command.opts(options[:options])

          `ssh #{flags}#{opts}#{host} #{Shellwords.escape(command)}`
        end

        def rsync(sources, dst, options = {})
          if options[:port]
            (options[:options] ||= {})[:e] = "ssh -p #{options[:port]}"
          end

          sources = [sources] unless sources.is_a?(Array)

          flags = Command.flags(options[:flags])
          opts  = Command.opts(options[:options])

          # http://serverfault.com/questions/234876/escaping-spaces-in-a-remote-path-when-using-rsync-over-a-remote-ssh-connection
          `rsync #{flags}#{opts}#{Shellwords.join(sources)} #{Shellwords.escape(dst[RSYNC_PATH_1])}#{Shellwords.escape(Shellwords.escape(dst[RSYNC_PATH_2]))}`
        end

        def sync_directories(sources, dst, options = {})
          rsync sources, dst,
                port: dst.port,
                flags: [:r, :v, :z, :p],
                options: { chmod: 'og=rx' }
        end

        def ensure_directory(dst)
          ssh dst.full_host, "mkdir -p #{Shellwords.escape(dst.path)}", port: dst.port
        end

        def list_directory(dst)
          res = ssh dst.full_host, "ls -1 #{Shellwords.escape(dst.path)}", port: dst.port
          if $? == 0
            res.split("\n").map(&:strip)
          else
            []
          end
        end

        def clear_directory(dst)
          ssh dst.full_host, "find #{Shellwords.escape(dst.path)} -mindepth 1 -maxdepth 1 -type d -exec rm -R {} +", port: dst.port
        end

        def file_exists?(dst)
          ssh dst.full_host, "test -f #{Shellwords.escape(dst.path)}", port: dst.port
        end

        def write_file(dst, content)
          f = Tempfile.new('gitdeploy')
          f.puts content
          f.flush

          rsync f.path, dst,
                port: dst.port,
                flags: [:r, :v, :z, :p],
                options: { chmod: 'og=rx' }

          f.close
          f.unlink
        end

        def read_file(dst)
          ssh dst.full_host, "cat #{Shellwords.escape(dst.path)}", port: dst.port
        end

        def copy_file(src, dst)
          rsync src, dst,
                port: dst.port,
                flags: [:r, :v, :z, :p],
                options: { chmod: 'og=rx' }
        end
      end
    end
  end
end
