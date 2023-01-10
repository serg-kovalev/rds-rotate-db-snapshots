require 'aws-sdk-rds'

class RdsRotateDbSnapshots
  module ActionWrappers
    def with_backoff(*method_names)
      method_names.each do |m|
        wrapper = Module.new do
          define_method(m) do |*args|
            reset_backoff
            begin
              super *args
            rescue Aws::RDS::Errors => e
              backoff
              retry
            end
            
          end
        end
        self.prepend wrapper
      end
    end
  end
end
