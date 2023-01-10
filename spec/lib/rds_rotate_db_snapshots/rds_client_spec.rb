require 'helper'

describe RdsRotateDbSnapshots::RdsClient do
  let(:options) { {
    :aws_access_key => "ACCESS_KEY",
    :aws_secret_access_key => "SECRET_KEY",
    :aws_session_token => "SESSION_TOKEN",
    :aws_region => "REGION"
  } }
  let(:rds_client) { RdsRotateDbSnapshots::RdsClient.new(options) }

  it 'configures the client with the correct credentials and region' do
    expect(rds_client.instance_variable_get(:@client).config.credentials).
      to have_attributes(access_key_id: "ACCESS_KEY", secret_access_key: "SECRET_KEY", session_token: "SESSION_TOKEN")
    expect(rds_client.instance_variable_get(:@client).config.region).to eq("REGION")
  end

  it 'delegates describe_db_snapshots method to the @client object' do
    expect(rds_client.instance_variable_get(:@client)).to receive(:describe_db_snapshots)
    rds_client.describe_db_snapshots
  end

  it 'delegates create_db_snapshot method to the @client object' do
    expect(rds_client.instance_variable_get(:@client)).to receive(:create_db_snapshot)
    rds_client.create_db_snapshot("test-snapshot")
  end

  it 'delegates delete_db_snapshot method to the @client object' do
    expect(rds_client.instance_variable_get(:@client)).to receive(:delete_db_snapshot)
    rds_client.delete_db_snapshot("test-snapshot")
  end
end
