require 'optparse'
require_relative 'options_parser/options'
class RdsRotateDbSnapshots
  class OptionsParser
    class NotImplementedError < StandardError; end
    class InvalidArgument < StandardError; end

    include RdsRotateDbSnapshots::OptionsParser::Options

    attr_reader :options, :script_name, :time_periods

    def initialize(script_name: nil, cli: false)
      @script_name = script_name
      @options = {
        aws_access_key: ENV.fetch("AWS_ACCESS_KEY_ID", nil),
        aws_secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY", nil),
        aws_session_token: ENV.fetch("AWS_SESSION_TOKEN", nil),
        aws_region: ENV.fetch("AWS_REGION", nil),
        pattern: nil,
        by_tags: nil,
        dry_run: false,
        backoff_limit: 15,
        create_snapshot: nil
      }
      @time_periods = {
        hourly: { seconds: 60 * 60, format: '%Y-%m-%d-%H', keep: 0, keeping: {} },
        daily: { seconds: 24 * 60 * 60, format: '%Y-%m-%d', keep: 0, keeping: {} },
        weekly: { seconds: 7 * 24 * 60 * 60, format: '%Y-%W', keep: 0, keeping: {} },
        monthly: { seconds: 30 * 24 * 60 * 60, format: '%Y-%m', keep: 0, keeping: {} },
        yearly: { seconds: 12 * 30 * 24 * 60 * 60, format: '%Y', keep: 0, keeping: {} }
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
        banner_opts o
        aws_opts o
        snapshot_create_opts o
        time_period_opts o
        extra_opts o
        not_supported_opts o
      end
    end
  end
end
