require 'helper'

describe RdsRotateDbSnapshots::OptionsParser do
  subject { RdsRotateDbSnapshots::OptionsParser.new(script_name: script_name, cli: true).parse! }

  let(:script_name) { "rds_rotate_snapshots.rb" }

  describe "#parse!" do
    before { ARGV.clear }

    it "parses options correctly" do
      ARGV.concat(["--aws-access-key", "ACCESS_KEY",
                   "--aws-secret-access-key", "SECRET_KEY",
                   "--aws-region", "REGION",
                   "--pattern", "PATTERN",
                   "--backoff-limit", "20",
                   "--create-snapshot", "snapshot"])
      options = subject

      expect(options[:aws_access_key]).to eq("ACCESS_KEY")
      expect(options[:aws_secret_access_key]).to eq("SECRET_KEY")
      expect(options[:aws_region]).to eq("REGION")
      expect(options[:pattern]).to eq("PATTERN")
      expect(options[:backoff_limit]).to eq("20")
      expect(options[:create_snapshot]).to eq("snapshot")
    end

    it "raises NotImplementedError when by-tags option is passed and it is not implemented" do
      ARGV.concat(["--by-tags", "tag=value,tag2=value"])

      expect { subject }.to raise_error(RdsRotateDbSnapshots::OptionsParser::NotImplementedError)
    end
  end
end
