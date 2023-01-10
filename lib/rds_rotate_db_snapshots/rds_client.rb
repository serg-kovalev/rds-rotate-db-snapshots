require 'forwardable'
require 'aws-sdk-rds'

class RdsRotateDbSnapshots
  class RdsClient
    extend Forwardable

    def_delegators :@client, :describe_db_snapshots, :create_db_snapshot, :delete_db_snapshot

    def initialize(options)
      Aws.config.update(
        access_key_id: options[:aws_access_key],
        secret_access_key: options[:aws_secret_access_key],
        region: options[:aws_region],
        session_token: options[:aws_session_token]
      )
      @client = Aws::RDS::Client.new
    end
  end
end
