require "helper"

describe RdsRotateDbSnapshots do
  subject { described_class.new(script_name: script_name, cli: cli) }

  let(:script_name) { "test" }
  let(:cli) { true }
  before do
    allow(Aws::RDS::Client).to receive(:new)
  end

  describe "on include" do
    it "adds action methods to the base class" do
      expect(described_class.instance_methods).to include(:rotate_em)
      expect(described_class.instance_methods).to include(:create_snapshot)
      expect(described_class.instance_methods).to include(:get_db_snapshots)
      expect(described_class.instance_methods).to include(:rotate_by_tags)
      expect(described_class.instance_methods).to include(:client)
      expect(described_class.instance_methods).to include(:time_periods)
    end
  end

  describe "#client" do
    it "returns an RdsClient" do
      expect(subject.client).to be_a(RdsRotateDbSnapshots::RdsClient)
    end
  end

  describe "#rds_client" do
    it "returns an RdsClient" do
      expect(subject.rds_client).to be_a(RdsRotateDbSnapshots::RdsClient)
    end
  end

  describe "#reset_backoff" do
    it "resets backoff counter" do
      subject.instance_variable_set(:@backoff_counter, 1)
      subject.reset_backoff
      expect(subject.instance_variable_get(:@backoff_counter)).to eq(0)
    end
  end

  describe "#time_periods" do
    it "returns time periods" do
      expect(subject.time_periods).to eq(
        :daily=>{:format=>"%Y-%m-%d", :keep=>0, :keeping=>{}, :seconds=>86400},
        :hourly => {:format=>"%Y-%m-%d-%H", :keep=>0, :keeping=>{}, :seconds=>3600},
        :monthly => {:format=>"%Y-%m", :keep=>0, :keeping=>{}, :seconds=>2592000},
        :weekly => {:format=>"%Y-%W", :keep=>0, :keeping=>{}, :seconds=>604800},
        :yearly=>{:format=>"%Y", :keep=>0, :keeping=>{}, :seconds=>31104000}
      )
    end
  end

  describe "#backoff" do
    it "backs off" do
      subject.instance_variable_set(:@backoff_counter, 1)
      expect(subject).to receive(:sleep)
      subject.send(:backoff)
    end
  end
end
