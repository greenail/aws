require 'rubygems'
require 'right_aws'

def wait_for_volume(volume_id,ec2)

test = false
 while (test == false)
        test = check_volume_status(volume_id,ec2)
        puts "test: #{test}"
        sleep 1
 end
puts "Waiting over ;)"
end

def check_volume_status(volume_id,ec2)

all_volumes = []
if (volume_id =~ /^snap/)
        all_volumes = ec2.describe_snapshots
elsif (volume_id =~ /^vol/)
        all_volumes = ec2.describe_volumes
end
 for vol in all_volumes
        aws_id = vol[:aws_id]
        if (aws_id == volume_id)
                status = vol[:aws_status]
                print status
                if (status == "available" || status == "completed"|| status == "in-use")
                        #logfile.print "Status Returned: #{status} for vol: #{aws_id}\n"
                        print "Status Returned: #{status} for vol: #{aws_id}\n"
                        return 1
                else
                        print "-"
                        return false
                end
       end
 end
return false
end

def grab_meta_data

end

