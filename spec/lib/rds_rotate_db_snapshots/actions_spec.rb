require 'helper'

RSpec.shared_examples 'rds_rotate_db_snapshots actions' do
  let(:rds_client) { instance_double(RdsRotateDbSnapshots::RdsClient) }
  let(:client) { rds_client }
  let(:options) do
    { 
      aws_access_key: 'ACCESS_KEY',
      aws_secret_access_key: 'SECRET_KEY',
      aws_region: 'REGION',
      pattern: 'test',
      dry_run: true,
      backoff_limit: 15
    }
  end
  let(:rds_snapshots) do
    [
      { snapshot_create_time: Time.now, db_instance_identifier: 'test_db', db_snapshot_identifier: 'test_snapshot' }
    ]
  end

  before do
    allow(subject).to receive(:client).and_return(rds_client)
    allow(rds_client).to receive(:describe_db_snapshots).and_return(rds_snapshots)
    allow(rds_client).to receive(:create_db_snapshot)
    allow(rds_client).to receive(:delete_db_snapshot)
  end

  describe "#rotate_em" do
    it "deletes the snapshots that are not part of the specified time periods" do
      expect(rds_client).to receive(:delete_db_snapshot)
      subject.rotate_em(rds_snapshots)
    end
  end

  describe "#create_snapshot" do
    it "creates a snapshot with the specified name" do
      expect(rds_client).to receive(:create_db_snapshot)
      subject.create_snapshot('test', ['test_db'])
    end
  end

  describe "#get_db_snapshots" do
    let(:snapshots) { double('snapshots', db_snapshots: rds_snapshots) }

    it "returns the list of snapshots from the client" do
      allow(snapshots).to receive(:[]).with(:marker).and_return(nil)
      expect(rds_client).to receive(:describe_db_snapshots).and_return(snapshots)
      snapshots = subject.get_db_snapshots(options)
      expect(snapshots).to eq(rds_snapshots)
    end
  end

end

class Test
  include RdsRotateDbSnapshots::Actions

  attr_reader :options

  def initialize(script_name: nil, cli: false, options: {})
    @script_name = script_name
    @options = options
    @cli = cli
    parse_options if cli?
    @backoff_counter = 0
  end

  def reset_backoff
    @backoff_counter = 0
  end

  def time_periods
    @options[:time_periods] || {}
  end

  private

  def cli?
    !!@cli
  end

  def parse_options
    @options = RdsRotateDbSnapshots::OptionsParser.new(script_name: @script_name, cli: @cli).parse!
  end

  def backoff
    @backoff_counter = @backoff_counter + 1
  end
end

describe RdsRotateDbSnapshots::Actions do
  subject { Test.new }

  it_behaves_like 'rds_rotate_db_snapshots actions'
end
