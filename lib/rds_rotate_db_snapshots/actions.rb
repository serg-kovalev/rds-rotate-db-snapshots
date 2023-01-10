class RdsRotateDbSnapshots
  module Actions
    def rotate_em(snapshots)
      # poor man's way to get a deep copy of our time_periods definition hash
      periods = Marshal.load(Marshal.dump(time_periods))

      snapshots.each do |snapshot|
        time = snapshot[:snapshot_create_time]
        db_id = snapshot[:db_instance_identifier]
        snapshot_id = snapshot[:db_snapshot_identifier]
        description = snapshot_id
        keep_reason = nil

        if options[:pattern] && description !~ /#{options[:pattern]}/
          puts "  #{time.strftime '%Y-%m-%d %H:%M:%S'} #{snapshot_id} Skipping snapshot with description #{description}"
          next
        end

        periods.keys.sort { |a, b| periods[a][:seconds] <=> periods[b][:seconds] }.each do |period|
          period_info = periods[period]
          keep = period_info[:keep]
          keeping = period_info[:keeping]

          time_string = time.strftime period_info[:format]
          next unless Time.now - time < keep * period_info[:seconds]

          if !keeping.key?(time_string) && keeping.length < keep
            keep_reason = period
            keeping[time_string] = snapshot
          end
          break
        end

        keep_reason = 'last snapshot' if keep_reason.nil? && snapshot == snapshots.last && options[:keep_last]

        if keep_reason.nil?
          puts "  #{time.strftime '%Y-%m-%d %H:%M:%S'} #{snapshot_id} Deleting"
          begin
            client.delete_db_snapshot(db_snapshot_identifier: snapshot_id) unless options[:dry_run]
          rescue Aws::RDS::Errors => e
            backoff
            retry
          end
        else
          puts "  #{time.strftime '%Y-%m-%d %H:%M:%S'} #{snapshot_id} Keeping for #{keep_reason}"
        end
      end
    end

    def create_snapshot(name, db_indentifier_ids)
      return if name.nil?

      name = name.gsub(/[^a-zA-Z0-9-]/, '')
      if name.size.positive?
        name = "#{name}-#{Time.now.strftime('%Y%m%d%H%M%S')}"
        db_indentifier_ids.each do |db_id|
          unless options[:dry_run]
            client.create_db_snapshot(db_snapshot_identifier: name,
                                      db_instance_identifier: db_id)
          end
          puts "  #{Time.now.strftime '%Y-%m-%d %H:%M:%S'} Creation snapshot #{name} is pending (db: #{db_id})"
        rescue Aws::RDS::Errors::InvalidDBInstanceStateFault => e
          backoff
          retry
        end
      else
        puts "invalid snapshot name format - #{name}"
        exit 1
      end
    end

    def get_db_snapshots(options)
      snapshots = []
      response = client.describe_db_snapshots(options)
      loop do
        snapshots += response.db_snapshots
        break unless response[:marker]

        response = client.describe_db_snapshots(options.merge(marker: response[:marker]))
      end
      snapshots
    end

    def rotate_by_tags
      snapshots = []
      options[:by_tags].each do |tag, value|
        snapshots = rrds.client.describe_tags(
          snapshot_type: 'manual', filters: { 'resource-type' => "snapshot", 'key' => tag, 'value' => value }
        ).delete_if { |e| e.status != 'available' }
        # TODO: re-work
        if snapshots.empty?
          puts "(tag,value)=(#{tag},#{value}) found no snapshots; nothing to rotate!"
          exit 0
        end
      end

      snapshots = get_db_snapshots(db_instance_identifier: snapshots.map(&:db_instance_identifier).uniq)
                  .delete_if { |e| !snapshots.include?(e.db_snapshot_identifier) }
                  .sort { |a, b| a[:snapshot_create_time] <=> b[:snapshot_create_time] }

      rotate_em snapshots
    end
  end
end
