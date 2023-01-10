require 'rubygems'
require_relative 'rds_rotate_db_snapshots/actions'
require_relative 'rds_rotate_db_snapshots/action_wrappers'
require_relative 'rds_rotate_db_snapshots/options_parser'
require_relative 'rds_rotate_db_snapshots/rds_client'

class RdsRotateDbSnapshots
  extend RdsRotateDbSnapshots::ActionWrappers
  include RdsRotateDbSnapshots::Actions

  attr_reader :options

  with_backoff :get_db_snapshots, :create_snapshot, :rotate_em

  def initialize(script_name: nil, cli: false, options: {})
    @script_name = script_name
    @options = options
    @cli = cli
    parse_options if cli?
    @backoff_counter = 0
  end

  def rds_client
    @rds_client ||= RdsRotateDbSnapshots::RdsClient.new(@options)
  end
  alias client rds_client

  def reset_backoff
    @backoff_counter = 0
  end

  def time_periods
    @options[:time_periods]
  end

  private

  def cli?
    !!@cli
  end

  def parse_options
    @options = RdsRotateDbSnapshots::OptionsParser.new(script_name: @script_name, cli: @cli).parse!
  end

  def backoff
    @backoff_counter += 1

    # TODO: re-work
    if options && options[:backoff_limit].positive? && options[:backoff_limit] < @backoff_counter
      puts "Too many backoff attempts. Sorry it didn't work out."
      exit 2
    end

    naptime = rand(60) * @backoff_counter
    puts "Backing off for #{naptime} seconds..."
    sleep naptime
  end
end
