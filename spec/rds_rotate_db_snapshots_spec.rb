require "helper"

describe RdsRotateDbSnapshots do
  describe "on include" do
    it "adds action methods to the base class" do
      expect(RdsRotateDbSnapshots.instance_methods).to include(:rotate_em)
      expect(RdsRotateDbSnapshots.instance_methods).to include(:create_snapshot)
      expect(RdsRotateDbSnapshots.instance_methods).to include(:get_db_snapshots)
      expect(RdsRotateDbSnapshots.instance_methods).to include(:rotate_by_tags)
      expect(RdsRotateDbSnapshots.instance_methods).to include(:client)
      expect(RdsRotateDbSnapshots.instance_methods).to include(:time_periods)
    end
  end
end
