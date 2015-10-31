module Gitdeploy
  module Protocols
    module Local
      class << self
        def rsync(sources, dst, options = {})
          flags = Command.flags(options[:flags])
          opts  = Command.opts(options[:options])

          `rsync #{flags}#{opts}#{Shellwords.join(sources)} #{Shellwords.escape(dst.path)}`
        end

        def sync_directories(sources, dst, options = {})
          rsync sources, dst,
                flags: [:r, :v, :z, :p],
                options: { chmod: 'og=rx' }
        end

        def ensure_directory(dst)
          FileUtils.mkdir_p(dst.path)
        end

        def remove_directory(dst)
          FileUtils.rm_rf(dst.path)
        end

        def list_directory(dst)
          ::Dir.entries(dst.path) - ['.', '..']
        rescue
          []
        end

        def clear_directory(dst)
          remove_directory(dst)
          ensure_directory(dst)
        end

        def file_exists?(dst)
          ::File.exist?(dst.path)
        end

        def write_file(dst, content)
          ::File.open(dst.path, 'w+') { |f| f.write(content) }
        end

        def read_file(dst)
          ::File.read(dst.path)
        end

        def copy_file(src, dst)
          FileUtils.cp_r(src, dst.path)
        end
      end
    end
  end
end
