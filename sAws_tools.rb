require 'rubygems'
require 'right_aws'

def wait_for_volume(volume_id,ec2,logfile)

test = false
 while (test == false)
        test = check_volume_status(volume_id,ec2,logfile)
        logfile.print "."
        sleep 1
 end
puts "Waiting over ;)"
end

def check_volume_status(volume_id,ec2,logfile)

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
                logfile.print "- #{status} -"
                if (status == "available" || status == "completed"|| status == "in-use")
                        #logfile.print "Status Returned: #{status} for vol: #{aws_id}\n"
                        logfile.print "Status Returned: #{status} for vol: #{aws_id}\n"
                        return 1
                else
                        logfile.print " sleep "
                        return false
                end
       end
 end
return false
end

def get_volumes(ec2)
all_volumes = ec2.describe_volumes
volumes = []
for vol in all_volumes
        instance = vol[:aws_instance_id]
        if instance == instance_id
                logfile.print "Found Master Instance: volume id: #{vol[:aws_id]}.\n"
                my_volume += vol[:aws_id]
        end
end
return volumes
end
def mounter(path,logfile)
	result = ""	
	counter = 10
	while (counter > 0)
		IO.popen('mount #{path} 2>&1', "r+") do |pipe| 
			result += pipe.read
		end
		logfile.print result
		result = ""
		#puts "Running Command: df -h |grep #{path} 2>&1"
		IO.popen("df -h |grep #{path} 2>&1", "r+") do |pipe| 
			result += pipe.read
		end
		if (result == "")
			print " Mounter Sleeping..."
		else
			puts result
			counter = 0
		end
		sleep 1
		counter -= 1
	end
end

