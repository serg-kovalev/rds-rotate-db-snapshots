require_relative 'helper'
require_relative '../lib/rds_rotate_db_snaphots/utils'
require 'minitest/autorun'

class TestClass
  extend RdsRotateDbSnapshots::Utils
end
class TestRDSRotateDBSnapshots < Minitest::Test
  def test_get_latest_snapshot
    # Test that the function returns the latest snapshot
    snapshots = [{'SnapshotCreateTime': '2022-01-01T00:00:00Z'},
                 {'SnapshotCreateTime': '2022-01-02T00:00:00Z'},
                 {'SnapshotCreateTime': '2022-01-03T00:00:00Z'}]
    latest_snapshot = TestClass.get_latest_snapshot(snapshots)
    assert_equal(latest_snapshot, {'SnapshotCreateTime': '2022-01-03T00:00:00Z'})
  end

  def test_delete_old_snapshots
    # Test that the function correctly deletes old snapshots
    snapshots = [{'DBSnapshotIdentifier': 'snapshot-1', 'SnapshotCreateTime': '2022-01-01T00:00:00Z'},
                 {'DBSnapshotIdentifier': 'snapshot-2', 'SnapshotCreateTime': '2022-01-02T00:00:00Z'},
                 {'DBSnapshotIdentifier': 'snapshot-3', 'SnapshotCreateTime': '2022-01-03T00:00:00Z'},
                 {'DBSnapshotIdentifier': 'snapshot-4', 'SnapshotCreateTime': '2022-01-04T00:00:00Z'},
                 {'DBSnapshotIdentifier': 'snapshot-5', 'SnapshotCreateTime': '2022-01-05T00:00:00Z'}]
    TestClass.delete_old_snapshots(snapshots, retention_days: 3)
    assert_equal(snapshots.length, 3)
    assert_equal(snapshots[0]['DBSnapshotIdentifier'], 'snapshot-3')
    assert_equal(snapshots[1]['DBSnapshotIdentifier'], 'snapshot-4')
    assert_equal(snapshots[2]['DBSnapshotIdentifier'], 'snapshot-5')
  end

  def test_delete_old_snapshots_no_snapshots
    # Test that the function returns an empty array when there are no snapshots
    snapshots = []
    TestClass.delete_old_snapshots(snapshots, retention_days: 3)
    assert_equal(snapshots, [])
  end
end
