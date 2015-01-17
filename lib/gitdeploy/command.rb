module Gitdeploy
  class Command
    class << self
      def flags(flags = nil)
        short = (flags || []).select { |a| a.to_s.length <= 1 }
        long  = (flags || []).select { |a| a.to_s.length > 1 }

        short.map!(&:to_s)
        long.map! { |flag| "--#{flag} "}

        "#{'-' + short.join unless short.empty?} #{long.join}"
      end

      def opts(opts = nil)
        (opts || {}).map do |k, v|
          "--#{k}=#{Shellwords.escape(v)} "
        end.join
      end
    end
  end
end
