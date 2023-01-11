class RdsRotateDbSnapshots
  class OptionsParser
    module Options
      def split_tag(hash, value)
        value.split(',').each do |pair|
          tag, value = pair.split('=', 2)
          raise InvalidArgument, "invalid tag=value format" if value.nil?

          hash[tag] = value
        end
      end

      def banner_opts(opt)
        opt.banner = "Usage: #{script_name} [options] <db_indentifier>\nUsage: #{script_name} " \
                     "--by-tags <tag=value,...> [other options]"
        opt.separator ""
      end

      def aws_opts(opt)
        opt.on("--aws-access-key ACCESS_KEY", "AWS Access Key") do |v|
          @options[:aws_access_key] = v
        end

        opt.on("--aws-secret-access-key SECRET_KEY", "AWS Secret Access Key") do |v|
          @options[:aws_secret_access_key] = v
        end

        opt.on("--aws-region REGION", "AWS Region") do |v|
          @options[:aws_region] = v
        end

        opt.on("--aws-session-token SESSION_TOKEN", "AWS session token") do |v|
          @options[:aws_session_token] = v
        end
      end

      def not_supported_opts(opt)
        opt.on("--by-tags TAG=VALUE,TAG=VALUE",
               "Instead of rotating specific snapshots, rotate over all the snapshots having the intersection of all " \
               "given TAG=VALUE pairs.") do |_v|
          @options[:by_tags] = {}
          raise NotImplementedError,
                'Hey! It\'s not implemented in RDS yet. Who knows, maybe they will add Tagging in RDS later.'
          # split_tag(@options[:by_tags], v)
        end
      end

      def snapshot_create_opts(opt)
        opt.on("--create-snapshot STRING", "Use this option if you want to create a snapshot") do |v|
          @options[:create_snapshot] = v
        end
      end

      def time_period_opts(opt)
        @time_periods.keys.sort { |a, b| @time_periods[a][:seconds] <=> @time_periods[b][:seconds] }.each do |period|
          opt.on("--keep-#{period} NUMBER", Integer, "Number of #{period} snapshots to keep") do |v|
            @time_periods[period][:keep] = v
          end
        end

        opt.on("--keep-last", "Keep the most recent snapshot, regardless of time-based policy") do |_v|
          @options[:keep_last] = true
        end
      end

      def extra_opts(opt)
        opt.on("--pattern STRING", "Snapshots without this string in the description will be ignored") do |v|
          @options[:pattern] = v
        end
        opt.on("--backoff-limit LIMIT",
               "Backoff and retry when hitting RDS Error exceptions no more than this many times. Default is 15") do |v|
          @options[:backoff_limit] = v
        end
        opt.on("--dry-run", "Shows what would happen without doing anything") do |_v|
          @options[:dry_run] = true
        end
      end
    end
  end
end
