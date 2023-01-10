$TESTING = true

require "simplecov"

SimpleCov.start do
  add_filter "/spec"
  minimum_coverage(75)

  if ENV['CI']
    require 'simplecov-lcov'

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = 'coverage/lcov.info'
    end

    formatter SimpleCov::Formatter::LcovFormatter
  end
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require "rds_rotate_db_snapshots"

require "rdoc"
require "rspec"
require "diff/lcs" # You need diff/lcs installed to run specs.
# require 'stringio'
require "webmock/rspec"

WebMock.disable_net_connect!(:allow => "coveralls.io")

$0 = "rds_rotate_db_snapshots"
ARGV.clear

RSpec.configure do |config|
  config.before do
    ARGV.replace []
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # def capture(stream)
  #   begin
  #     stream = stream.to_s
  #     eval "$#{stream} = StringIO.new"
  #     yield
  #     result = eval("$#{stream}").string
  #   ensure
  #     eval("$#{stream} = #{stream.upcase}")
  #   end

  #   result
  # end

  def source_root
    File.join(File.dirname(__FILE__), "fixtures")
  end

  def destination_root
    File.join(File.dirname(__FILE__), "sandbox")
  end

  def silence_warnings
    old_verbose = $VERBOSE
    $VERBOSE = nil
    yield
  ensure
    $VERBOSE = old_verbose
  end

  # true if running on windows, used for conditional spec skips
  #
  # @return [TrueClass/FalseClass]
  def windows?
    Gem.win_platform?
  end

  # alias silence capture
end
