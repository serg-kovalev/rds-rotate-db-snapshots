require 'helper'
class Test
  include RdsRotateDbSnapshots::Actions

  attr_reader :options

  def initialize(script_name: nil, options: {})
    @script_name = script_name
    @options = options
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

  def backoff
    @backoff_counter += 1
  end
end

describe RdsRotateDbSnapshots::Actions do
  let(:test_class) { Test.new(script_name: 'test', options: options) }
  let(:client) { double("client") }
  let(:time_periods) do
    {
      hourly: { seconds: 60 * 60, format: '%Y-%m-%d-%H', keep: 0, keeping: {} },
      daily: { seconds: 24 * 60 * 60, format: '%Y-%m-%d', keep: 1, keeping: {} },
      weekly: { seconds: 7 * 24 * 60 * 60, format: '%Y-%W', keep: 0, keeping: {} },
      monthly: { seconds: 30 * 24 * 60 * 60, format: '%Y-%m', keep: 0, keeping: {} }
    }
  end
  let(:options) do
    {
      aws_access_key: 'ACCESS_KEY',
      aws_secret_access_key: 'SECRET_KEY',
      aws_region: 'REGION',
      pattern: 'test',
      dry_run: false,
      backoff_limit: 15,
      time_periods: time_periods
    }
  end
  let(:rds_snapshots) do
    [
      { snapshot_create_time: Time.now - (24 * 3600), db_instance_identifier: 'test_db',
        db_snapshot_identifier: 'test_snapshot' },
      { snapshot_create_time: Time.now, db_instance_identifier: 'test_db', db_snapshot_identifier: 'test_snapshot2' }
    ]
  end

  before do
    allow(client).to receive(:describe_db_snapshots).and_return(rds_snapshots)
    allow(test_class).to receive(:client).and_return(client)
  end

  describe "#rotate_em" do
    it "deletes the snapshots that are not part of the specified time periods" do
      expect(client).to receive(:delete_db_snapshot)
      test_class.rotate_em(rds_snapshots)
    end

    context 'when the snapshot is not matched with pattern' do
      let(:rds_snapshots) do
        [
          { snapshot_create_time: Time.now - (49 * 3600), db_instance_identifier: 'test_db',
            db_snapshot_identifier: 'other_snapshot' },
          { snapshot_create_time: Time.now - (48 * 3600), db_instance_identifier: 'test_db',
            db_snapshot_identifier: 'test_snapshot' },
          { snapshot_create_time: Time.now, db_instance_identifier: 'test_db',
            db_snapshot_identifier: 'test_snapshot2' }
        ]
      end

      it "deletes the snapshots that are matched with pattern" do
        expect(client).to receive(:delete_db_snapshot).with(db_snapshot_identifier: 'test_snapshot')
        test_class.rotate_em(rds_snapshots)
      end
    end
  end

  describe "#create_snapshot" do
    it "creates a snapshot with the specified name" do
      expect(client).to receive(:create_db_snapshot)
      test_class.create_snapshot('test', ['test_db'])
    end

    context "when snaphost name is invalid" do
      it "raises an error SystemExit" do
        expect { test_class.create_snapshot('$#', ['test_db']) }.to raise_error(SystemExit)
      end
    end
  end

  describe "#get_db_snapshots" do
    let(:snapshots) { double('snapshots', db_snapshots: rds_snapshots) }

    it "returns the list of snapshots from the client" do
      allow(snapshots).to receive(:[]).with(:marker).and_return(nil)
      expect(client).to receive(:describe_db_snapshots).and_return(snapshots)
      snapshots = test_class.get_db_snapshots(options)
      expect(snapshots).to eq(rds_snapshots)
    end
  end
end
