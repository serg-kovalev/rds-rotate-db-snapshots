require 'optparse'

class RdsRotateDbSnapshots
  class OptionsParser
    class NotImplementedError < StandardError; end
    class InvalidArgument < StandardError; end

    attr_reader :options, :script_name, :time_periods

    def initialize(script_name: nil, cli: false)
      @script_name = script_name
      @options = {
        :aws_access_key => ENV["AWS_ACCESS_KEY_ID"],
        :aws_secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"],
        :aws_session_token => ENV["AWS_SESSION_TOKEN"],
        :aws_region => ENV["AWS_REGION"],
        :pattern => nil,
        :by_tags => nil,
        :dry_run => false,
        :backoff_limit => 15,
        :create_snapshot => nil
      }
      @time_periods = {
        :hourly  => { :seconds => 60 * 60, :format => '%Y-%m-%d-%H', :keep => 0, :keeping => {} },
        :daily   => { :seconds => 24 * 60 * 60, :format => '%Y-%m-%d', :keep => 0, :keeping => {} },
        :weekly  => { :seconds => 7 * 24 * 60 * 60, :format => '%Y-%W', :keep => 0, :keeping => {} },
        :monthly => { :seconds => 30 * 24 * 60 * 60, :format => '%Y-%m', :keep => 0, :keeping => {} },
        :yearly  => { :seconds => 12 * 30 * 24 * 60 * 60, :format => '%Y', :keep => 0, :keeping => {} },
      }
      @cli = cli
      init_cli_parser if cli?
    end

    def parse!
      @parser.parse!
      @options.merge(time_periods: @time_periods)
    end

    private

    def cli?
      !!@cli
    end

    def init_cli_parser
      @parser ||= OptionParser.new do |o|
        o.banner = "Usage: #{script_name} [options] <db_indentifier>\nUsage: #{script_name} --by-tags <tag=value,...> [other options]"
        o.separator ""
      
        o.on("--aws-access-key ACCESS_KEY", "AWS Access Key") do |v|
          @options[:aws_access_key] = v
        end
      
        o.on("--aws-secret-access-key SECRET_KEY", "AWS Secret Access Key") do |v|
          @options[:aws_secret_access_key] = v
        end
      
        o.on("--aws-region REGION", "AWS Region") do |v|
          @options[:aws_region] = v
        end
      
        o.on("--aws-session-token SESSION_TOKEN", "AWS session token") do |v|
          @options[:aws_session_token] = v
        end
      
        o.on("--pattern STRING", "Snapshots without this string in the description will be ignored") do |v|
          @options[:pattern] = v
        end
      
        o.on("--by-tags TAG=VALUE,TAG=VALUE", "Instead of rotating specific snapshots, rotate over all the snapshots having the intersection of all given TAG=VALUE pairs.") do |v|
          @options[:by_tags] = {}
          raise NotImplementedError, 'Hey! It\'s not implemented in RDS yet. Who knows, maybe they will add Tagging in RDS later.'
          split_tag(@options[:by_tags],v)
        end
      
        o.on("--backoff-limit LIMIT", "Backoff and retry when hitting RDS Error exceptions no more than this many times. Default is 15") do |v|
          @options[:backoff_limit] = v
        end
      
        o.on("--create-snapshot STRING", "Use this option if you want to create a snapshot") do |v|
          @options[:create_snapshot] = v
        end
      
        @time_periods.keys.sort { |a, b| @time_periods[a][:seconds] <=> @time_periods[b][:seconds] }.each do |period|
          o.on("--keep-#{period} NUMBER", Integer, "Number of #{period} snapshots to keep") do |v|
            @time_periods[period][:keep] = v
          end
        end
      
        o.on("--keep-last", "Keep the most recent snapshot, regardless of time-based policy") do |v|
          @options[:keep_last] = true
        end
      
        o.on("--dry-run", "Shows what would happen without doing anything") do |v|
          @options[:dry_run] = true
        end
      end

      def split_tag(hash,v)
        v.split(',').each do |pair|
          tag, value = pair.split('=',2)
          if value.nil?
            raise InvalidArgument, "invalid tag=value format"
          end
          hash[tag] = value
        end
      end
    end
  end
end
