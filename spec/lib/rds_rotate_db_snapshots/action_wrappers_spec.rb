require 'helper'

class TestClass
  def initialize
    @backoff_counter = 0
    @options = { backoff_limit: 5 }
  end

  def test_method
    raise Aws::RDS::Errors::ServiceError.new(nil, 'service error')
  end

  def reset_backoff
    @backoff_counter = 0
  end

  def backoff
    @backoff_counter = @backoff_counter + 1

    raise StandardError, 'gave up' if @options[:backoff_limit] > 0 && @options[:backoff_limit] < @backoff_counter
  end

  extend RdsRotateDbSnapshots::ActionWrappers

  with_backoff :test_method
end

describe RdsRotateDbSnapshots::ActionWrappers do
  subject { TestClass.new }

  describe "#with_backoff" do
    it "does not retry if the exception raised is Aws::RDS::Errors::ExpiredToken" do
      allow(subject).to receive(:test_method).and_raise(Aws::RDS::Errors::ExpiredToken.new(nil, 'token expired'))
      expect(subject).not_to receive(:reset_backoff)
      expect(subject).not_to receive(:backoff)
      expect{subject.test_method}.to raise_error(Aws::RDS::Errors::ExpiredToken)
    end

    it "retries if the exception raised is Aws::RDS::Errors::ServiceError" do
      expect(subject).to receive(:backoff).exactly(6).and_call_original

      expect{ subject.test_method }.to raise_error(StandardError, 'gave up')
    end
  end
end
